_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'
Options = require '../../options'
Messages = require '../../messages'

Messages.setWithPrefix 'table.cell', Link: 'link'

SelectedObjects = require '../../models/selected-objects'
types = require '../../core/type-assertions'

# Null safe isa test.
_isa = (type, commonType) ->
  if commonType?
    type.isa commonType
  else
    false

# We memoize this to avoid re-walking the inheritance heirarchy.
#
# eg. In a worst case scenario like the call `(isa Enhancer, BioEntity)`, for
# each enhancer in the table we would have to examine each of the 5 types in
# the inheritance heirarchy between Enhancer and BioEntity.
#
# We replace null common types with '!' since that is not a legal class name.
#
isa = _.memoize _isa, (type, ct) -> "#{ type }<#{ ct ? '!' }"

# A Cell representing a single attribute value.
class Cell extends CoreView

  # This is a table cell.
  tagName: 'td'

  # Identifying class name.
  className: 'im-result-field'

  # A function that when called returns an HTML string suitable
  # for direct inclusion. The default formatter is very simple
  # and just returns the escaped value.
  #
  formatter: (imobject, service, value) ->
    if value? then (_.escape value) else Templates.null_value

  parameters: ['query', 'selectedObjects', 'tableState']

  optionalParameters: ['formatter']

  parameterTypes:
    selectedObjects: (types.InstanceOf SelectedObjects, 'SelectedObjects')
    formatter: types.Callable
    tableState: types.CoreModel

  initialize: ->
    super
    @listen()

  id: -> _.uniqueId 'im_table_cell_'

  listen: ->
    @listenToEntity()
    @listenToSelectedObjects()
    @listenTo Options, 'change:TableCell.*', @reRender
    @listenToTableState()

  listenToTableState: -> # TODO - make this work!
    @listenTo @tableState, 'change:picking', @setInputDisplay
    @listenTo @tableState, 'change:previewOwner', @_closeOwnPreview
    @listenTo @tableState, 'change:highlightNode', @_setHighlit

  initState: ->
    @_setSelected()
    @_setSelectable()

  # Event listeners.

  # Close our preview if another cell has opened theirs
  _closeOwnPreview: ->
    myId = @el.id
    currentOwner = @tableState.get 'previewOwner'
    @children.preview?.hide() unless (myId is currentOwner)

  _setHighlit: ->
    myNode = @model.get('node')
    @model.set highlit: (myNode.equals @tableState.get 'highlightNode')

  listenToSelectedObjects: ->
    arr = 'add remove reset'
    @listenTo @selectedObjects, arr, @_setSelected
    @listenTo @selectedObjects, "#{ arr } change:commonType", @_setSelectable

  # Listen to the entity that backs this cell, updating the value if it
  # changes. This is important for cell formatters so that they can
  # request new information in a uniform manner.
  listenToEntity: ->
    @listenTo (@model.get 'entity'), 'change', @updateValue 

  modelEvents: ->
    'change:entity': @onChangeEntity # make sure we unbind if it changes.
    'change:selectable': @toggleInputDisabled
    'change:selected': @onChangeSelected
    'change:highlit': @setActiveClass

  events: ->
    'shown.bs.popover': => @cellPreview?.reposition() # FIXME - move to the cell preview.
    'show.bs.popover': (e) => # FIXME - move to the cell preview.
      @model.get('query').trigger 'showing:preview', @el
      e?.preventDefault() if @model.get('cell').get 'is:selecting'
    'hide.bs.popover': (e) => @model.get('cell').cachedPopover?.detach() # FIXME - move to the cell preview.
    'click': @activateChooser
    'click a.im-cell-link': (e) =>
      # Prevent bootstrap from closing dropdowns, etc.
      e?.stopPropagation()
      # Allow the table to handle this event, if
      # it chooses to.
      e.object = @model # one arg good, more args bad.
      @options.query.trigger 'object:view', e # FIXME - replace with an event bus.

  # Event handlers.
  select: -> @selectedObjects.add @model.get('entity')

  unselect: -> @selectedObjects.remove @model.get('entity')

  toggleSelection: ->
    ent = @model.get 'entity'
    return unless ent?
    if found = @selectedObjects.get ent
      @selectedObjects.remove found
    else
      @selectedObjects.add found

  _setSelected: -> @model.set 'selected': @selectedObjects.get(@)?

  _setSelectable: ->
    commonType = @selectedObjects.state.get('commonType')
    size = @selectedObjects.size()
    # Selectable when nothing is selected or it is of the right type.
    selectable = (size is 0) or (isa @type, commonType)
    @model.set 'selectable'

  onChangeEntity: -> # Should literally never happen.
    @stopListening @model.previous 'entity'
    @listenToEntity()

  activateChooser: ->
    selectable = @tableState.get 'picking'
    selectable = @model.get 'selectable'
    if selectable and selecting # then toggle state of 'selected'
      @toggleSelection()

  updateValue: -> _.defer =>
    @$('.im-displayed-value').html @formatter(@model.get('cell'))

  selectingStateChange: ->
    {checked, disabled, display} = @getInputState()
    @$el.toggleClass "active", checked
    @$('input').attr({checked, disabled}).css {display}

  getFormattedValue: ->
    {entity, value} = @model.pick 'entity', 'value'
    {service} = @query
    @formatter.call null, entity, service, value

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

  getInputState: ->
    selecting = @tableState.get 'picking'
    {selected, selectable} = @model.pick 'selected', 'selectable'
    checked = selected
    disabled = not selectable
    display = if selecting and selectable then 'inline' else 'none'
    {checked, disabled, display}

  template: Templates.template 'table-cell'

  postRender: ->
    attrType = @model.get('column').getType()
    @$el.addClass 'im-type-' + attrType.toLowerCase()
    @setActiveClass()
    @setupPreviewOverlay() if @model.get('entity').get('id')

  onChangeSelected: ->
    @setActiveClass()
    @$('input').css checked: @getInputState().checked

  setActiveClass: ->
    {highlit, selected} = @model.pick 'highlit', 'selected'
    @$el.toggleClass 'active', (highlit or selected)

  setInputDisplay: ->
    @$('input').css display: @getInputState().display

  toggleInputDisabled: ->
    @$('input').attr disabled: @getInputState().disabled

  # The below needs lots of work. FIXME

  setupPreviewOverlay: ->
    options =
      container: @el
      containment: '.im-query-results'
      html: true # well, technically we are using Elements.
      title: => @model.get 'typeName' # function, as not available until render is called
      trigger: intermine.options.CellPreviewTrigger # click or hover
      delay: {show: 250, hide: 250} # Slight delays to prevent jumpiness.
      classes: 'im-cell-preview'
      content: @getPopoverContent
      placement: @getPopoverPlacement

    @cellPreview?.destroy()
    @cellPreview = new intermine.bootstrap.DynamicPopover @el, options

  getPopoverPlacement: (popover) =>
    table = @$el.closest ".im-table-container"
    {left} = @$el.offset()

    limits = table.offset()
    _.extend limits,
      right: limits.left + table.width()
      bottom: limits.top + table.height()

    w = @$el.width()
    h = @$el.height()
    elPos = @$el.offset()

    pw = $(popover).outerWidth()
    ph = $(popover)[0].offsetHeight

    fitsOnRight = left + w + pw <= limits.right
    fitsOnLeft = limits.left <= left - pw

    if fitsOnLeft
      return 'left'
    if fitsOnRight
      return 'right'
    else
      return 'top'

  getPopoverContent: =>
    cell = @model.get 'cell'
    return cell.cachedPopover if cell.cachedPopover?

    type = cell.get 'obj:type'
    id = cell.get 'id'

    popover = @popover = new intermine.table.cell.Preview
      service: @model.get('query').service
      schema: @model.get('query').model
      model: {type, id}

    content = popover.$el

    popover.on 'rendered', => @cellPreview.reposition()
    popover.render()

    cell.cachedPopover = content

