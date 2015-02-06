_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'
Options = require '../../options'
Messages = require '../../messages'
CellModel = require '../../models/cell'

Messages.setWithPrefix 'table.cell', Link: 'link'

SelectedObjects = require '../../models/selected-objects'
types = require '../../core/type-assertions'

# Null safe isa test.
# :: (PathInfo, String) -> boolean
_isa = (type, commonType) ->
  if commonType?
    type.isa commonType
  else
    false

classyPopover = Templates.template 'classy-popover'

# We memoize this to avoid re-walking the inheritance heirarchy, and because
# we know a-priori that the same call will be repeated many times in the same
# table for each change in common type (eg. in a table of 50 rows, which
# has one Department column, two Employee columns and one Manager column (ie. a very
# small table), then a change in the common type will results in 50x4 = 200
# examinations of the common type, all of which are one of four calls, either
# Department < CT, Employee < CT, CEO < CT or Manager < CT).
#
# eg. In a worst case scenario like the call `(isa Enhancer, BioEntity)`, for
# each enhancer in the table we would have to examine each of the 5 types in
# the inheritance heirarchy between Enhancer and BioEntity.
#
# The key for the memoization is the concatenation of the queried type and the
# given common type. We replace null common types with '!' since that is not a
# legal class name, and thus guaranteed not to collide with valid types.
#
# :: (PathInfo, String) -> boolean
isa = _.memoize _isa, (type, ct) -> "#{ type }<#{ ct ? '!' }"

# A Cell representing a single attribute value.
# Forms a pair with ./subtable
class Cell extends CoreView

  Model: CellModel

  # This is a table cell.
  tagName: 'td'

  # Identifying class name.
  className: 'im-result-field'

  template: Templates.template 'table-cell'

  # A function that when called returns an HTML string suitable
  # for direct inclusion. The default formatter is very simple
  # and just returns the escaped value.
  # 
  # Note that while a property of this class, this function
  # is called in such a way that it never has access to the this
  # reference.
  formatter: (imobject, service, value) ->
    if value? then (_.escape value) else Templates.null_value

  parameters: [
    'model', # We need a cell model to function.
    'service', # We pass the service on to some child elements.
    'selectedObjects', # the set of selected objects.
    'tableState' # {selecting, previewOwner, highlitNode}
    'popovers' # creates popovers
  ]

  optionalParameters: ['formatter']

  parameterTypes:
    model: (types.InstanceOf CellModel, 'models/cell')
    selectedObjects: (types.InstanceOf SelectedObjects, 'SelectedObjects')
    formatter: types.Callable
    tableState: types.Model
    service: types.Service

  initialize: ->
    super
    @listen()

  initState: ->
    @setSelected()
    @setSelectable()
    @setHighlit()

  # getPath is part of the RowCell API
  getPath: -> @model.get 'column'

  getType: -> @model.get 'node'

  id: -> _.uniqueId 'im_table_cell_'

  listen: ->
    @listenToEntity()
    @listenToSelectedObjects()
    @listenTo Options, 'change:TableCell.*', @reRender
    @listenTo Options, 'change:TableCell.*', @delegateEvents
    @listenToTableState()

  listenToTableState: ->
    @listenTo @tableState, 'change:selecting', @setInputDisplay
    @listenTo @tableState, 'change:previewOwner', @closeOwnPreview
    @listenTo @tableState, 'change:highlitNode', @setHighlit

  listenToSelectedObjects: ->
    arr = 'add remove reset'
    @listenTo @selectedObjects, arr, @setSelected
    @listenTo @selectedObjects, "#{ arr } change:commonType", @setSelectable

  modelEvents: ->
    'change:entity': @onChangeEntity # make sure we unbind if it changes.

  stateEvents: ->
    'change:highlit': @setActiveClass
    'change:selectable': @setInputDisabled
    'change:selected': @onChangeSelected
    'change:showPreview': @onChangeShowPreview

  events: ->
    events =
      'show.bs.popover': @onShowPreview
      'hide.bs.popover': @onHidePreview
      'click a.im-cell-link': @onClickCellLink

    opts = Options.get 'TableCell'
    trigger = opts.PreviewTrigger
    if trigger is 'hover'
      events['mouseover'] = => _.delay (=> @showPreview()), opts.HoverDelay
      events['mouseout'] = @hidePreview
      events['click'] = @activateChooser
    else if trigger is 'click'
      events['click'] = @clickTogglePreview
    else
      throw new Error "Unknown cell preview: #{ trigger}"

    return events

  # Event listeners.

  # The purpose of this handler is to propagate an event up the DOM
  # so that higher level listeners can capture it and possibly prevent
  # the page navigation (by e.preventDefault()) if they choose to do
  # something else.
  onClickCellLink: (e) ->
    # Prevent bootstrap from closing dropdowns, etc.
    e?.stopPropagation()
    # Allow the table to handle this event, if it so chooses
    # attach the entity for handlers to inspect.
    e.object = @model.get('entity').toJSON()
    @$el.trigger 'view.im.object', e

  # Close our preview if another cell has opened theirs
  closeOwnPreview: ->
    myId = @el.id
    currentOwner = @tableState.get 'previewOwner'
    @hidePreview() unless (myId is currentOwner)

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
    @tableState.set previewOwner: null if (myId is currentOwner)

  select: -> @selectedObjects.add @model.get('entity')

  unselect: -> @selectedObjects.remove @model.get('entity')

  toggleSelection: ->
    ent = @model.get 'entity'
    return unless ent?
    if found = @selectedObjects.get ent
      @selectedObjects.remove found
    else
      @selectedObjects.add found

  setSelected: -> @state.set 'selected': @selectedObjects.get(@model.get('entity'))?

  setSelectable: ->
    commonType = @selectedObjects.state.get('commonType')
    size = @selectedObjects.size()
    # Selectable when nothing is selected or it is of the right type.
    selectable = (size is 0) or (isa @getType(), commonType)
    @state.set {selectable}

  setHighlit: ->
    myNode = @model.get('node')
    @state.set highlit: (myNode.equals @tableState.get 'highlitNode')

  onChangeEntity: -> # Should literally never happen.
    @stopListening @model.previous 'entity'
    @listenToEntity()

  activateChooser: ->
    selecting = @tableState.get 'selecting'
    selectable = @state.get 'selectable'
    if selectable and selecting # then toggle state of 'selected'
      @toggleSelection()

  showPreview: -> if @rendered
    @children.popover?.render()

  hidePreview: -> if @rendered
    @$el.popover 'hide'

  onChangeShowPreview: ->
    if @state.get('showPreview') then @showPreview() else @hidePreview()

  clickTogglePreview: ->
    if @tableState.get('selecting')
      @activateChooser()
    else
      @state.toggle 'showPreview'

  onChangeSelected: ->
    @setActiveClass()
    @$('input').css checked: @getInputState().checked

  updateValue: -> _.defer =>
    @$('.im-displayed-value').html @getFormattedValue()

  setActiveClass: ->
    {highlit, selected} = @state.pick 'highlit', 'selected'
    @$el.toggleClass 'active', (highlit or selected)

  setInputDisplay: ->
    @$('input').css display: @getInputState().display

  setInputDisabled: ->
    @$('input').attr disabled: @getInputState().disabled

  # Rendering logic.

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

    for domain, url of opts.ExternalLinkIcons when reportUri.match domain
      data.icon ?= url

    return data

  getFormattedValue: ->
    {entity, value} = @model.pick 'entity', 'value'
    @formatter.call null, entity, @service, value

  # Special get data method just for the input.
  # which is probably a good indication it should be its own view.
  getInputState: ->
    selecting = @tableState.get 'selecting'
    {selected, selectable} = @model.pick 'selected', 'selectable'
    checked = selected
    disabled = not selectable
    display = if selecting and selectable then 'inline' else 'none'
    {checked, disabled, display}

  canHavePreview: -> @model.get('entity').get('id')?

  postRender: ->
    attrType = @model.get('column').getType()
    @$el.addClass 'im-type-' + attrType.toLowerCase()
    @setActiveClass()
    @children.popover ?= @initPreview() if @canHavePreview()

  # Code associated with the preview.
  
  getPreviewContainer: ->
    con = []
    candidates = ['.im-query-results', '.im-table-container', 'table', 'body']
    while con.length is 0
      sel = candidates.shift()
      con = @$el.closest sel
    return con
  
  initPreview: ->
    # Create the popover now, but no data will be fetched until render is called.
    content = popoverFactory.get @model.get 'entity'

    @$el.popover
      trigger: 'manual'
      template: (classyPopover classes: 'item-preview')
      placement: 'auto left'
      container: @getPreviewContainer()
      html: true # well, technically we are using Elements.
      title: => @model.get 'typeName' # see CellModel
      content: content.el

    # This is how we actually trigger the popover.
    @listenTo view, 'rendered', => @$el.popover 'show'
    return view

