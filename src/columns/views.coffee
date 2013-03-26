do ->

  NODE_TEMPLATE = _.template """
    <h4><%- node %></h4>
    <ul class="im-possible-attributes"></ul>
  """

  class PossibleColumn extends intermine.views.ItemView

    tagName: 'li'

    className: 'im-possible-column'

    initialize: ->
      @on 'rendered', @showDisplayName, @
      @on 'rendered', @setClassName, @
      @model.on 'destroy', @remove, @

    events:
      'click': 'addToExportedList'

    addToExportedList: ->
      @model.trigger 'selected', @model unless @model.get 'alreadySelected'

    setClassName: ->
      @$el.toggleClass 'disabled', @model.get('alreadySelected')

    showDisplayName: ->
      # Demeter violations coming up!! TODO.
      # Here we want the name without any preconfigured bits. So instead of 
      # Gene > Organism . Name for Gene.organism.name, get
      # Organism > Name
      path = @model.get 'path'
      basicPath = "#{ path.getParent().getType().name }.#{ path.end.name }"
      canonical = path.model.getPathInfo basicPath
      canonical.getDisplayName().done (name) =>
        @$('.im-field-name').text name.split(' > ').pop()
        @model.trigger 'displayed-name'

    template: _.template """
      <a href="#">
        <i class="<% if (alreadySelected) { %>#{ intermine.icons.Check }<% } else { %>#{ intermine.icons.UnCheck }<% } %>"></i>
        <span class="im-field-name"><%- path %></span>
      </a>
    """

  class PopOver extends Backbone.View

    tagName: 'ul'
    className: 'im-possible-attributes'

    initialize: ->
      @collection = new Backbone.Collection
      @collection.on 'selected', @selectPathForExport, @
      @collection.on 'displayed-name', @sortUL, @
      @initFields()

    initFields: ->
      @collection.reset()
      for path in @options.node.getChildNodes() when @isSuitable path
        alreadySelected = @options.exported.any (x) -> path.equals x.get 'path'
        @collection.add {path, alreadySelected}

    isSuitable: (p) ->
      ok = p.isAttribute() and (intermine.options.ShowId or (p.end.name isnt 'id'))

    remove: ->
      @collection.each (m) ->
        m?.destroy()
        m?.off()
      @collection.off()
      super(arguments...)

    sortUL: ->
      $lis = @$ 'li'
      $lis.detach()
      lis = $lis.get()
      sorted = _.sortBy lis, (li) -> $(li).find('.im-field-name').text()

      @$el.append sorted
      @trigger 'needs-repositioning'

    selectPathForExport: (model) ->
      console.log "We want #{ model.get 'path' }"
      @collection.remove model
      @options.exported.add path: model.get 'path'
      model.destroy()
      model.off()

    render: ->
      @collection.each (model) =>
        item = new PossibleColumn {model}
        item.render()
        @$el.append item.el
      this

  class QueryNode extends Backbone.View

    tagName: 'div'

    className: 'im-query-node btn'

    initialize: ->
      exported = @model.collection.exported
      node = @model.get 'node'
      @content = new PopOver({node, exported})

      @listenTo exported, 'add remove', @render, @
      @listenTo @content, 'needs-repositioning', => @popover?.reposition()
      @listenTo @model, 'destroy', @remove, @
      @listenTo @model.collection, 'popover-toggled', (originator) =>
        @popover?.hide() unless @model is originator
      @model.once 'popover-toggled', => @content.render()

    remove: ->
      @popover?.hide()
      @popover?.destroy()
      @content?.remove()
      delete @content
      delete @popover
      super(arguments...)

    events: ->
      shown: => @popover?.reposition(); @model.trigger 'popover-toggled', @model
      hide: => @content.$el.detach() # This preserves events on the popover

    render: ->

      data = @model.toJSON()
      @$el.empty()
      @$el.html NODE_TEMPLATE data
      ul = @$ 'ul'

      data.node.getDisplayName().done (name) =>
        [parents..., end] = name.split(' > ')
        @$('h4').text end

      options =
        containment: '.tab-pane'
        html: true
        trigger: 'click'
        placement: 'top'
        content: => @content.$el
        title: => @$('h4').text()

      @popover = new intermine.bootstrap.DynamicPopover @el, options
      
      this

  class PossibleColumns extends Backbone.View

    tagName: 'div'

    className: 'im-possible-columns btn-group'

    initialize: ->
      @nodes = []

    remove: ->
      while node = @nodes.pop()
        node.remove()
      super arguments...

    render: ->

      @collection.each (model) =>
        item = new QueryNode {model}
        @nodes.push item
        el = item.render().$el
        @$el.append el

      this

  scope 'intermine.columns.views', {PossibleColumns}
