define 'actions/list-dialogue', ->

  class ListDialogue extends Backbone.View
    tagName: "li"
    className: "im-list-dialogue dropdown"

    usingDefaultName: true

    initialize: (@query) ->
      @listOptions = opts = new Backbone.Model
      @types = {}
      @query.on "imo:selected", (type, id, selected) =>
        return unless @listOptions? # from another time...
        if selected
          @types[id] = type
        else
          delete @types[id]
        types = _.values @types
        
        opts.set estSize: types.length

        if types.length > 0
          m = @query.model
          commonType = m.findCommonTypeOfMultipleClasses(types)
          opts.set type: commonType

      opts.on 'change:query', (_, q) -> q.count (n) -> opts.set estSize: n
      opts.on 'change:query', => @$('.modal').modal('show').find('form').show()
      opts.on 'change:name', @updateNameDisplay, @
      opts.on 'change:name', @checkName, @
      opts.on 'change:type', @newCommonType, @
      opts.on 'change:estSize', @bindEstSize, @

    updateNameDisplay: ->
      console.log "Updating name to #{ @listOptions.get('name') }"
      @$('.im-list-name').val @listOptions.get 'name'

    remove: ->
      for thing in ['listOptions']
        @[thing].off()
        delete @[thing]
      super()

    bindEstSize: ->
      estSize = @listOptions.get 'estSize'
      hasSelectedItems = estSize > 0
      @$('.btn-primary').attr disabled: not hasSelectedItems
      @$('.im-selection-instruction').hide()
      @$('form').show()
      @$el.addClass 'im-picked'
      @nothingSelected() unless hasSelectedItems

    newCommonType: ->
      # Broadcast a message to the cells so they can decide to enable or
      # disable their check-boxes.
      @query.trigger "common:type:selected", @listOptions.get 'type'

    nothingSelected: ->
        @$('.im-selection-instruction').slideDown()
        @$('form').hide()
        @$el.removeClass 'im-picked'
        @query.trigger "selection:cleared"

    events: ->
      'hidden': 'onHidden'
      'change .im-list-name': 'listNameChanged'
      'submit form': 'ignore'
      'click form': 'ignore'
      'click .btn-cancel': 'stop'
      'click .btn-primary': 'create'
      'click .im-minimise': 'minimise'

    minimise: ->
      @$('.control-group').slice(1).slideToggle()
      @$('.im-minimise').toggleClass 'im-collapsed'

    onHidden: (e) ->
      @remove() if e and $(e.target).is('.modal')

    startPicking: ->
      @$('.modal').addClass 'im-picking-list-items'
      @query.trigger "start:list-creation"
      @nothingSelected()
      m = @$('.modal').show -> $(@).addClass("in").draggable(handle: "h2")
      @$('.modal-header h2').css(cursor: "move").tooltip
        title: "Drag me around!"
        placement: 'bottom'

    stop: (e) ->
        @query.trigger "stop:list-creation"
        modal = @$('.modal')
        if modal.is '.ui-draggable'
            @remove()
        else
            modal.modal('hide')

    ignore: (e) ->
        e.preventDefault()
        e.stopPropagation()
    
    listNameChanged: (e) ->
      @listOptions.set customName: true, name: $(e.target).val()

    getLists: ->
      # Caching version of fetch lists. This caches lists requests within a specific window.
      now = new Date().getTime()
      if not @listPromise or @listPromise.made_at < now - intermine.options.ListFreshness
        @listPromise = @query.service.fetchLists()
        @listPromise.made_at = now
      @listPromise


    checkName: ->
      selector = '.im-list-name'
      message = intermine.messages.actions.ListNameDuplicate
      @clearError selector

      @getLists().done (ls) =>
        chosen = @listOptions.get 'name'
        isDup = _.any ls, (l) -> l.authorized and l.name is chosen
        @setError selector, message if isDup

    setError: (selector, message) ->
      $input = @$ selector
      $input.next().text message
      $input.parent().addClass 'error'

    clearError: (selector) ->
      $input = @$ selector
      $input.next().text ''
      $input.parent().removeClass 'error'

    create: -> throw new Error "Override me!"

    openDialogue: (type, q) ->
      type ?= @query.root
      q    ?= @query.clone()
      @listOptions.set query: q, type: type

    render: ->
        @$el.append @html
        @$('.modal').modal(show: false)
        this

