define 'actions/list-dialogue', ->

  class ListDialogue extends Backbone.View
    tagName: "li"
    className: "im-list-dialogue dropdown"

    usingDefaultName: true

    initialize: (@query) ->
        @types = {}
        @model = new Backbone.Model()
        @query.on "imo:selected", (type, id, selected) =>
            if selected
                @types[id] = type
            else
                delete @types[id]
            types = _(@types).values()
            
            if types.length > 0
                m = @query.model
                commonType = m.findCommonTypeOfMultipleClasses(types)
                @newCommonType(commonType) unless commonType is @commonType
            @selectionChanged()

    selectionChanged: (n) =>
        n or= _(@types).values().length
        hasSelectedItems = !!n
        @$('.btn-primary').attr disabled: !hasSelectedItems
        @$('.im-selection-instruction').hide()
        @$('form').show()
        @nothingSelected() if n < 1

    newCommonType: (type) ->
        @commonType = type
        @query.trigger "common:type:selected", type

    nothingSelected: ->
        @$('.im-selection-instruction').slideDown()
        @$('form').hide()
        @query.trigger "selection:cleared"

    events: ->
        'change .im-list-name': 'listNameChanged'
        'submit form': 'ignore'
        'click form': 'ignore'
        'click .btn-cancel': 'stop'

    startPicking: ->
        @query.trigger "start:list-creation"
        @nothingSelected()
        m = @$('.modal').show -> $(@).addClass("in").draggable(handle: "h2")
        @$('.modal-header h2').css(cursor: "move").tooltip title: "Drag me around!"
        @$('.btn-primary').unbind('click').click => @create()

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
    
    listNameChanged: ->
        @usingDefaultName = false

        $target = @$ '.im-list-name'
        $target.parent().removeClass """error"""
        $target.next().text ''
        chosen = $target.val()

        @query.service.fetchLists (ls) =>
            for l in ls
                if l.name is chosen
                    $target.next().text """This name is already taken"""
                    $target.parent().addClass """error"""


    create: (q) ->
        throw "Override me!"

    openDialogue: (type, q) ->
        type ?= @query.root
        q    ?= @query.clone()
        q.joins = {}
        @newCommonType(type)
        q?.count @selectionChanged
        @$('.modal').modal("show").find('form').show()
        @$('.btn-primary').unbind('click').click => @create(q, type)

    render: ->
        @$el.append @html
        @$('.modal').modal(show: false).on "hidden", => @remove()
        this

