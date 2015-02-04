_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

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

CELL_HTML = (data) ->
  {url, host} = data
  data.isForeign = (url and not url.match host)
  data.target = if data.isForeign then '_blank' else ''
  _CELL_HTML data

# FIXME FIXME FIXME - this is a work in progress!
class Cell extends CoreView

    tagName: "td"
    className: "im-result-field"

    # A function that when called returns an HTML string suitable for direct inclusion.
    formatter: (imobject) ->
      value = @model.get('value')
      if value?
        _.escape value
      else
        Templates.null_value

    parameters: ['query', 'selectedObjects']

    initialize: ->
      super

      @_setSelected()
      @_setSelectable()

      @listenToEntity()
      @listenToSelectedObjects()

      @path = @model.get('column') # Cell Views must have a path :: PathInfo property.

      for opt in ['IndicateOffHostLinks', 'CellPreviewTrigger', 'ExternalLinkIcons']
        intermine.onChangeOption opt, @render, @

    # Event listeners.
    listenToSelectedObjects: ->
      @listenTo @selectedObjects, 'add remove reset', @_setSelected
      @listenTo @selectedObjects, 'add remove reset change:commonType', @_setSelectable

    listenToEntity: ->
      entity = @model.get 'entity'
      @listenTo entity, 'change', @updateValue # Allow formatters to recalculate the value.

    modelEvents: ->
      'change:entity': @onChangeEntity # make sure we unbind if it changes.
      'change:selected change:selectable change:selecting': @reRender

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

    ### FIXME!!: replace all these events by listening to a table state that reports:
    #  popovercell - which cell is currently showing a popover (maybe none of them)
    #  picking - whether the table is selecting (initiated by the list dialogues)
    #  hoveredNode - which column (node) is hovered
   
    listenToQuery: (q) ->
      onListCreation = =>
        @model.get('cell').set 'is:selecting': true
      onStopListCreation = =>
        @model.get('cell').set 'is:selecting': false, 'is:selected': false
      onShowingPreview = (el) => # Close ours if another is being opened.
        @cellPreview?.hide() unless el is @el
      onStartHighlightNode = (node) =>
        if @model.get('node')?.toString() is node.toString()
          @$el.addClass "im-highlight"
      onStopHighlight = => @$el.removeClass "im-highlight"
      listenToReplacement = (replacement) =>
        q.off "start:list-creation", onListCreation
        q.off "stop:list-creation", onStopListCreation
        q.off 'showing:preview', onShowingPreview
        q.off "start:highlight:node", onStartHighlightNode
        q.off "stop:highlight", onStopHighlight
        q.off "replaced:by", listenToReplacement
        @listenToQuery replacement

      q.on "start:list-creation", onListCreation
      q.on "stop:list-creation", onStopListCreation
      q.on 'showing:preview', onShowingPreview
      q.on "start:highlight:node", onStartHighlightNode
      q.on "stop:highlight", onStopHighlight
      q.on "replaced:by", listenToReplacement
    ###

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

    remove: ->
      @popover?.remove()
      super

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

    updateValue: -> _.defer =>
      @$('.im-displayed-value').html @formatter(@model.get('cell'))

    getInputState: ->
      {selected, selectable, selecting} = @model.get('cell').selectionState()
      checked = selected
      disabled = not selectable
      display = if selecting and selectable then 'inline' else 'none'
      {checked, disabled, display}

    selectingStateChange: ->
      {checked, disabled, display} = @getInputState()
      @$el.toggleClass "active", checked
      @$('input').attr({checked, disabled}).css {display}

    getData: ->
      {IndicateOffHostLinks, ExternalLinkIcons} = intermine.options
      field = @model.get('field')
      data =
        value: (@formatter.call @, @model.get 'entity')
        rawValue: @model.get('value')
        field: field
        url: @model.get('cell').get('service:url')
        host: if IndicateOffHostLinks then window.location.host else /.*/
        icon: null
      _.extend data, @getInputState()

      unless /^http/.test(data.url)
        data.url = @model.get('cell').get('service:base') + data.url

      for domain, url of ExternalLinkIcons when data.url.match domain
        data.icon ?= url
      data

    render: ->
      data = @getData()
      @$el.addClass 'im-type-' + @path.getType().toLowerCase()
      @$el.addClass 'active' if data.checked
      @$el.html CELL_HTML data
      @setupPreviewOverlay() if @model.get('cell').get('id')
      this

    activateChooser: ->
      s = @model.pick 'selectable', 'selecting'
      if s.selectable and s.selecting # then toggle state of 'selected'
        @toggleSelection()

