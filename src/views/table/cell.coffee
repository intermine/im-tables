_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'
Options = require '../../options'
Messages = require '../../messages'
CellModel = require '../../models/cell'
Formatting = require '../../formatting'

Messages.setWithPrefix 'table.cell',
  Link: 'link'
  NullEntity: 'No <%= type %>'

SelectedObjects = require '../../models/selected-objects'
types = require '../../core/type-assertions'

popoverTemplate = Templates.template('classy-popover') classes: 'item-preview'

# Null safe isa test. Tests if the path is an instance of the
# given type, eg: PathInfo(Department.employees) isa 'Employee' => true
# :: (PathInfo, String) -> boolean
_compatible = (path, ct) ->
  if ct? then path.model.findSharedAncestor(path, ct)? else false

# We memoize this to avoid re-walking the inheritance heirarchy, and because
# we know a-priori that the same call will be repeated many times in the same
# table for each change in common type (eg. in a table of 50 rows, which
# has one Department column, two Employee columns and one Manager column (ie. a very
# small table), then a change in the common type will results in 50x4 = 200
# examinations of the common type, all of which are one of four calls, either
# Department < CT, Employee < CT, CEO < CT or Manager < CT).
#
# eg. In a worst case scenario like the call `(compatible Enhancer, BioEntity)`, for
# each enhancer in the table we would have to examine each of the 5 types in
# the inheritance heirarchy between Enhancer and BioEntity.
#
# The key for the memoization is the concatenation of the queried type and the
# given common type. We replace null common types with '!' since that is not a
# legal class name, and thus guaranteed not to collide with valid types.
#
# :: (PathInfo, String) -> boolean
compatible = _.memoize _compatible, (p, ct) -> "#{ p }<#{ ct ? '!' }"

# A Cell representing a single attribute value.
# Forms a pair with ./subtable
module.exports = class Cell extends CoreView

  Model: CellModel

  # This is a table cell.
  tagName: 'td'

  # Identifying class name.
  className: 'im-result-field'

  # Scoped unique element id.
  id: -> _.uniqueId 'im_table_cell_'

  # A function that when called returns an HTML string suitable
  # for direct inclusion. The default formatter is very simple
  # and just returns the escaped value.
  #
  # Note that while a property of this class, this function
  # is called in such a way that it never has access to the this
  # reference.
  formatter: Formatting.defaultFormatter

  # Initialization

  parameters: [
    'model',           # We need a cell model to function.
    'service',         # We pass the service on to some child elements.
    'selectedObjects', # the set of selected objects.
    'tableState',      # provides {selecting, previewOwner, highlitNode}
    'popovers'         # creates popovers
  ]

  optionalParameters: ['formatter']

  parameterTypes:
    model: (types.InstanceOf CellModel, 'models/cell')
    selectedObjects: (types.InstanceOf SelectedObjects, 'SelectedObjects')
    formatter: types.Callable
    tableState: types.Model
    service: types.Service
    popovers: (new types.StructuralTypeAssertion 'HasGet', get: types.Function)

  initialize: ->
    super
    @listen()

  initState: ->
    @setSelected()
    @setSelectable()
    @setHighlit()
    @setMinimised()

  # getPath is part of the RowCell API
  # :: -> PathInfo
  getPath: -> @model.get 'column'

  # Return the Path representing the query node of this column.
  # :: -> PathInfo
  getType: ->
    node = @model.get 'node'
    entityType = @model.get('entity').get('class')
    if entityType? then node.model.makePath(entityType) else node

  # Event wiring:

  listen: ->
    @listenToEntity()
    @listenToSelectedObjects()
    @listenToOptions()
    @listenToTableState()

  listenToOptions: -> # these events are expected to be rare.
    @listenTo Options, 'change:TableCell.IndicateOffHostLinks', @reRender
    @listenTo Options, 'change:TableCell.ExternalLinkIcons', @reRender
    @listenTo Options, 'change:TableCell.PreviewTrigger', @onChangeTrigger

  listenToTableState: -> # these events deal with co-ordination with global table state.
    ts = @tableState
    @listenTo ts, 'change:selecting',    @setInputDisplay
    @listenTo ts, 'change:previewOwner', @closeOwnPreview
    @listenTo ts, 'change:highlitNode',  @setHighlit
    @listenTo ts, 'change:minimisedColumns', @setMinimised

  # We listen to find out if the user selected us by clicking on another related cell.
  listenToSelectedObjects: ->
    objs = @selectedObjects
    @listenTo objs, 'add remove reset',                   @setSelected
    @listenTo objs, 'add remove reset change:commonType', @setSelectable

  modelEvents: -> # The model for a cell is pretty static.
    'change:entity': @onChangeEntity # make sure we unbind if it changes.

  stateEvents: -> # these events cause DOM twiddling.
    'change:highlit change:selected': @setActiveClass
    'change:selectable': @onChangeSelectable
    'change:selected': @setInputChecked
    'change:showPreview': @onChangeShowPreview
    'change:minimised': @reRender # nothing for it - full re-render is required.

  events: -> # the specific DOM event set depends on the configured click behaviour.
    events =
      'show.bs.popover': @onShowPreview
      'hide.bs.popover': @onHidePreview
      'click a.im-cell-link': @onClickCellLink

    opts = Options.get 'TableCell'
    trigger = opts.PreviewTrigger
    if trigger is 'hover'
      events['mouseover .im-cell-link'] = @showPreview
      events['mouseout .im-cell-link'] = @hidePreview
      events['click'] = @activateChooser
    else if trigger is 'click'
      events['click'] = @clickTogglePreview
    else
      throw new Error "Unknown cell preview: #{ trigger}"

    return events

  # Event listeners.

  onChangeTrigger: ->
    @destroyPreview()
    @initPreview()
    @delegateEvents()

  # The purpose of this handler is to propagate an event up the DOM
  # so that higher level listeners can capture it and possibly prevent
  # the page navigation (by e.preventDefault()) if they choose to do
  # something else.
  onClickCellLink: (e) ->
    # When selecting, it just acts to select.
    if @tableState.get('selecting')
      e.preventDefault()
      return

    # Allow the table to handle this event, if it so chooses
    # attach the entity for handlers to inspect.
    e.object = @model.get('entity').toJSON()
    @$el.trigger 'view.im.object', e

  # Close our preview if another cell has opened theirs
  closeOwnPreview: ->
    myId = @el.id
    currentOwner = @tableState.get 'previewOwner'
    @hidePreview() unless myId is currentOwner

  # Listen to the entity that backs this cell, updating the value if it
  # changes. This is important for cell formatters so that they can
  # request new information in a uniform manner.
  listenToEntity: ->
    @listenTo (@model.get 'entity'), 'change', @updateValue

  # Event handlers.

  onShowPreview: -> @tableState.set previewOwner: @el.id

  onHidePreview: -> # make sure we disclaim ownership.
    myId = @el.id
    currentOwner = @tableState.get 'previewOwner'
    @tableState.set previewOwner: null if myId is currentOwner

  toggleSelection: ->
    ent = @model.get 'entity'
    return unless ent?
    if found = @selectedObjects.get ent
      @selectedObjects.remove found
    else
      @selectedObjects.add ent

  setSelected: -> @state.set 'selected': @selectedObjects.get(@model.get('entity'))?

  setSelectable: ->
    commonType = @selectedObjects.state.get('commonType')
    size = @selectedObjects.size()
    # Selectable when nothing is selected or it is of the right type.
    selectable = (size is 0) or (compatible @getType(), commonType)
    @state.set {selectable}

  setHighlit: ->
    myNode = @model.get('node')
    highlit = @tableState.get 'highlitNode'
    @state.set highlit: (highlit? and (String(myNode) is String(highlit)))

  setMinimised: ->
    myColumn = @model.get('column')
    minimised = @tableState.get('minimisedColumns').contains(myColumn)
    @state.set {minimised}

  onChangeEntity: ->
    # Should literally never happen - we should probably throw an error.
    prev = @model.previous 'entity'
    delete @_has_id
    @stopListening(prev) if prev?
    @listenToEntity()

  clickTogglePreview: -> # click handler when the preview trigger is 'click'
    @activateChooser() or @state.toggle 'showPreview'

  activateChooser: -> # click handler when the preview trigger is 'hover'
    # can only select things with ids.
    return unless @hasID()
    selecting = @tableState.get 'selecting'
    selectable = @state.get 'selectable'
    if selectable and selecting # then toggle state of 'selected'
      @toggleSelection()

  # Cachable query of the entity.
  hasID: -> @_has_id ?= @model.get('entity').get('id')?

  showPreview: -> @state.set showPreview: true
  hidePreview: -> @state.set showPreview: false

  _showPreview: -> if @rendered
    return if @tableState.get('selecting') # don't show previews when selecting.
    opts = Options.get 'TableCell'
    show = =>
      # We test here too since it may have been hidden during the hover delay.
      if @state.get('showPreview') then @children.popover?.render()
    if opts.PreviewTrigger is 'hover'
      _.delay show, opts.HoverDelay
    else
      show()

  _hidePreview: -> if @children.popover?.rendered
    @popoverTarget?.popover 'hide'

  onChangeShowPreview: ->
    if @state.get('showPreview') then @_showPreview() else @_hidePreview()

  onChangeSelectable: ->
    @setDisabledCellClass()
    @setInputDisabled()

  # Rather than full re-renders, which would get expensive for many cells,
  # we just reach in and twiddle these specific DOM attributes:

  updateValue: -> _.defer =>
    @$('.im-displayed-value').html @getFormattedValue()

  setActiveClass: ->
    {highlit, selected} = @state.pick 'highlit', 'selected'
    @$el.toggleClass 'active', (highlit or selected)

  setInputChecked: ->
    @$('input').prop checked: @getInputState().checked

  setInputDisplay: ->
    @$('input').css display: @getInputState().display

  setDisabledCellClass: ->
    @$el.toggleClass 'im-not-selectable', (not @state.get 'selectable')

  setInputDisabled: ->
    @$('input').prop disabled: @getInputState().disabled

  # Rendering logic.

  template: Templates.template 'table-cell'

  getData: ->
    opts = Options.get 'TableCell'
    host = if opts.IndicateOffHostLinks then global.location.host else /.*/

    data = @model.toJSON()
    data.formattedValue = @getFormattedValue()
    data.input = @getInputState()
    data.icon = null
    data.url = reportUri = data.entity['report:uri']
    data.isForeign = (reportUri and not reportUri.match host)
    data.target = if data.isForeign then '_blank' else ''
    data.NULL_VALUE = Templates.null_value

    for domain, url of opts.ExternalLinkIcons when reportUri?.match domain
      data.icon ?= url

    _.extend @getBaseData(), data

  # The mechanism by which we apply the formatter the cell.
  # We call the foratter with the entity, its service and the raw value.
  # We use call with this set to null so that we don't leak the API of
  # this class to the formatters.
  #
  # If the value is null, then we always return null.
  getFormattedValue: ->
    {entity, value} = @model.pick 'entity', 'value'
    if value? then @formatter.call(null, entity, @service, value) else null

  # Special get data method just for the input.
  # which is probably a good indication it should be its own view.
  getInputState: ->
    selecting = @tableState.get 'selecting'
    {selected, selectable} = @state.pick 'selected', 'selectable'
    checked = selected
    disabled = not selectable
    display = if selecting then 'inline' else 'none'
    {checked, disabled, display}

  # InterMine objects (i.e. objects with ids) can have previews.
  # We find the preview information using `Query::findById` and
  # queries that use the `id` property, so this is a requirement.
  canHavePreview: -> @hasID() and (not @state.get 'minimised')

  # Make sure this element has the correct classes, and initialise the preview popover.
  postRender: ->
    @setAttrClass()
    @setActiveClass()
    @setMinimisedClass()
    @setDisabledCellClass()
    @setFormatterClasses()
    @initPreview()

  setAttrClass: ->
    attrType = @model.get('column').getType()
    @$el.addClass 'im-type-' + attrType.toLowerCase()

  setMinimisedClass: -> @$el.toggleClass 'im-minimised', @state.get('minimised')

  setFormatterClasses: ->
    cls = @formatter.classes
    @$el.addClass cls if cls?
    target = @formatter.target
    @$el.addClass target if target?

  # Code associated with the preview.

  getPreviewContainer: ->
    con = []
    # we are bound to find one of these
    candidates = ['.im-query-results', '.im-table-container', '.panel', 'table', 'body']
    while candidates.length and (con.length is 0)
      con = @$el.closest candidates.shift()
    return con

  removeAllChildren: ->
    @destroyPreview()
    if @children.popover?
      @stopListeningTo(@children.popover)
      @$el.popover('destroy') if @children.popover.rendered
    super

  destroyPreview: -> if @children.popover?
    @stopListeningTo(@children.popover)
    @popoverTarget?.popover('destroy') if @children.popover.rendered
    delete @popoverTarget
    @removeChild 'popover'

  popoverTarget: null

  initPreview: ->
    return if @children.popover? or (not @canHavePreview())
    # Create the popover now, but no data will be fetched until render is called.
    content = @popovers.get @model.get 'entity'
    trigger = Options.get 'TableCell.PreviewTrigger'
    @popoverTarget = if trigger is 'hover' then @$('.im-cell-link') else @$el

    @listenToOnce content, 'rendered', =>
      container = @getPreviewContainer()
      @popoverTarget.popover
        trigger: 'manual'
        template: popoverTemplate
        placement: 'auto left'
        container: container
        html: true # well, technically we are using Elements.
        title: => @model.get 'typeName' # see CellModel
        content: content.el

    # This is how we actually trigger the popover, hence it
    # is imporant to call re-render on the preview when we want
    # to show it inside the popover - see `::showPreview()`
    @listenTo content, 'rendered', => @popoverTarget.popover 'show'
    @children.popover = content
