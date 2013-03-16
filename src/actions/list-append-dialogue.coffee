define 'actions/list-append-dialogue', using 'actions/list-dialogue', 'html/append-list', (ListDialogue, HTML) ->

  OPTION_TEMPLATE = _.template """
    <option value="<%- name %>">
      <%- name %> (<%= size %> <%- things %>)
    </option>
  """

  makeOption = (list) -> OPTION_TEMPLATE _.extend {}, list,
    things: intermine.utils.pluralise list.type, list.size

  class ListAppender extends ListDialogue

    html: HTML

    events: -> _.extend super(),
      'change select': 'setTarget'

    setTarget: ->
      name = @$('select').val()
      @listOptions.set list: (l for l in @__ls when name is l.name)[0]

    displayType: ->
      {estSize, type} = @listOptions.toJSON()
      @$('.im-item-type').text intermine.utils.pluralise type, estSize

    initialize: ->
      super arguments...
      @listOptions.on 'change:estSize', (opts, n) => @$('.im-item-count').text n
      @listOptions.on 'change:type', @displayType, @
      @listOptions.on 'change:type', @onlyShowCompatibleOptions, @

    nothingSelected: ->
      super()
      @$('form select option').each (i, elem) =>
        $(elem).attr disabled: false

    getSuitabilityFilter: ->
      {model} = @query
      {type} = @listOptions.toJSON()
      pi = model.getPathInfo type

      (list) -> list.authorized and pi.isa list.type

    onlyShowCompatibleOptions: ->
      {list, type} = @listOptions.toJSON()
      {service} = @query
      select = @$ 'form select'
      select.empty()

      service.fetchLists().done (ls) =>
        @__ls = ls
        suitable = ls.filter @getSuitabilityFilter()
        for l in suitable
          opt = $ makeOption l
          select.append opt

        if list
          select.val(list.name)
        else
          @listOptions.set list: suitable[0]

        @$('.btn-primary').attr disabled: suitable.length < 1
        @$('.im-none-compatible-error').toggle suitable.length < 1

    doAppend: ->
      ids = _.keys @types
      {query, list} = @listOptions.toJSON()
      {service} = @query
      listQ = (query or {select: ["id"], from: list.type, where: {id: ids}})

      service.query(listQ).then (q) -> q.appendToList list.name

    create: ->

      unless @listOptions.has 'list'
        cg = @$('.im-receiving-list').closest('.control-group').addClass 'error'
        ilh = @$('.help-inline').text("No receiving list selected").show()
        backToNormal = ->
          ilh.fadeOut 1000, ->
            ilh.text ""
            cg.removeClass "error"
        _.delay backToNormal, 5000
        return false

      promise = @doAppend()

      promise.done (updated) =>
        added = updated.size - @listOptions.get('list').size
        @query.trigger "list-update:success", updated, added
        @stop()

      promise.fail (xhr, level, message) =>
        err = try
          JSON.parse(xhr.responseText).error
        catch e
          message
        @query.trigger "list-update:failure", err

    render: ->
      super()
      #@listOptions.trigger 'change:type'
      this

    startPicking: ->
      super()
      @$('.im-none-compatible-error').hide()

  scope 'intermine.actions.lists', {ListAppender}

  ListAppender
