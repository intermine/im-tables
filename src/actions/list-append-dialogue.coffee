define 'actions/list-append-dialogue', using 'actions/list-dialogue', 'html/append-list', (ListDialogue, HTML) ->

  class ListAppender extends ListDialogue

    html: HTML

    selectionChanged: (n) =>
      super(n)
      n or= _(@types).values().length
      @$('.im-item-count').text n
      @$('.im-item-type').text intermine.utils.pluralise @commonType, n
      @nothingSelected if n < 1

    nothingSelected: ->
      super()
      @$('form select option').each (i, elem) =>
        $(elem).attr disabled: false

    newCommonType: (type) ->
      super(type)
      @onlyShowCompatibleOptions()

    onlyShowCompatibleOptions: ->
      type = @commonType
      m = @query.service.model
      compatibles = 0
      @$('form select option').each (i, elem) =>
        $o = $(elem)
        $o.attr disabled: true

        if type and elem.value
          path = m.getPathInfo type
          compat = path.isa $o.data "type"
          $o.attr disabled: !compat
          compatibles++ if compat
      @$('.btn-primary').attr disabled: compatibles < 1
      @$('.im-none-compatible-error').toggle compatibles < 1 if type

    create: (q) ->
      ids = _(@types).keys()
      receiver = @$ '.im-receiving-list'
      unless lName = receiver.val()
        cg = receiver.closest('.control-group').addClass 'error'
        ilh = @$('.help-inline').text("No receiving list selected").show()
        backToNormal = ->
            ilh.fadeOut 1000, ->
                ilh.text ""
                cg.removeClass "error"
        _.delay backToNormal, 5000
        return false

      selectedOption = receiver.find(':selected').first()
      targetType = selectedOption.data 'type'
      targetSize = selectedOption.data 'size'

      listQ = (q or {select: ["id"], from: targetType, where: {id: ids}})

      @query.service.query listQ, (q) =>
        promise = q.appendToList receiver.val(), (updatedList) =>
          @query.trigger "list-update:success", updatedList, updatedList.size - parseInt(targetSize, 10)
          @stop()
        promise.fail (xhr, level, message) =>
          if xhr.responseText
            message = (JSON.parse xhr.responseText).error
          @query.trigger "list-update:failure", message

    render: ->
      super()
      @fillSelect()

      this

    fillSelect: ->
      @query.service.fetchLists (ls) =>
        toOpt = (l) => @make "option"
            , value: l.name, "data-type": l.type, "data-size": l.size
            , "#{l.name} (#{l.size} #{intermine.utils.pluralise(l.type, l.size)})"

        @$('.im-receiving-list').append(ls.filter((l) -> l.authorized).map toOpt)
        @onlyShowCompatibleOptions()
      this

    startPicking: ->
      super()
      @$('.im-none-compatible-error').hide()

  scope 'intermine.actions.lists', {ListAppender}

  ListAppender
