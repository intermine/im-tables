define 'actions/new-list-dialogue', using 'actions/list-dialogue', 'models/uniq-items', 'html/new-list', (ListDialogue, UniqItems, HTML) ->

  ILLEGAL_LIST_NAME_CHARS = /[^\w\s\(\):+\.-]/g

  class ListCreator extends ListDialogue

    html: HTML

    initialize: (@query) ->
      super(@query)
      @query.service.whoami (me) =>
        @canTag = me.username?
        if @rendered and not @canTag
          @hideTagOptions()
      @tags  = new UniqItems()
      @suggestedTags = new UniqItems()
      @tags.on "add", @updateTagBox
      @suggestedTags.on "add", @updateTagBox
      @tags.on "remove", @updateTagBox

      @initTags()

    hideTagOptions: () -> @$('.im-tag-options').hide()

    newCommonType: ->
      super()
      return if @listOptions.get('customName')

      type = @listOptions.get 'type'
      {service, model} = @query
      now = new Date()
      dateStr = "#{ now }".replace(/\s\d\d:\d\d:\d\d\s.*$/, '')
      text = "#{ type } list - #{ dateStr }"
      cd = model.classes[type]
      ids = _.keys(@types)

      @listOptions.set name: text, customName: false

      for categoriser in intermine.options.ListCategorisers
        [first, rest...] = categoriser.split(/\./)
        if cd.fields[first]?
          if ids?.length
            oq =
              select: categoriser
              from: type,
              where: {id: ids}
            querying = service.rows(oq).then (rows) =>
              if rows.length is 1
                @listOptions.set
                  name: "#{ type } list for #{ rows[0][0] } - #{ dateStr }"
                  customName: false
          else
            oq = (@listOptions.get('query') or @query).clone()
            querying = oq.summarise(categoriser, 1).then (items, {uniqueValues}) =>
              if uniqueValues is 1
                @listOptions.set
                  name: "#{ type } list for #{ items[0].item } - #{ dateStr }"
                  customName: false
        
          querying.always => @avoidNameDuplication()
          return
      
      @avoidNameDuplication()

    avoidNameDuplication: ->
      text = textBase = @listOptions.get 'name'
      copyNo = 1
      {service, model} = @query
      @getLists().done (ls) => for l in _.sortBy(ls, (l) -> l.name)
        if l.name is text
          text = "#{textBase} (#{ copyNo++ })"
          @listOptions.set name: text, customName: false

    openDialogue: (type, q) ->
        super(type, q)
        @initTags()

    initTags: ->
      @tags.reset()
      @suggestedTags.reset()
      add = (tag) => @suggestedTags.add tag, {silent: true}
      for c in @query.constraints then do (c) ->
          title = c.title or c.path.replace(/^[^\.]+\./, "")
          if c.op is "IN"
              add "source: #{c.value}"
          else if c.op is "="
              add "#{title}: #{c.value}"
          else if c.op is "<"
              add "#{title} below #{c.value}"
          else if c.op is ">"
              add "#{title} above #{c.value}"
          else if c.type
              add "#{title} is a #{c.type}"
          else
              add "#{title} #{c.op} #{c.value or c.values}"

      now = new Date()
      add "month: #{now.getFullYear()}-#{now.getMonth() + 1}"
      add "year: #{now.getFullYear()}"
      add "day: #{now.getFullYear()}-#{now.getMonth() + 1}-#{now.getDate()}"
      @updateTagBox()
    
    events: -> _.extend super(),
      'click .remove-tag': 'removeTag'
      'click .accept-tag': 'acceptTag'
      'click .im-confirm-tag': 'addTag'
      'click .btn-reset': 'reset'
      'click .control-group h5': 'rollUpNext'
      'change .im-list-desc': 'updateDesc'

    updateDesc: (e) ->
      @listOptions.set description: $(e.target).val()

    rollUpNext: (e) ->
      $(e.target).next().slideToggle()
      $(e.target).find("i").toggleClass("icon-chevron-right icon-chevron-down")

    reset: ->
      for field in ["name", "desc", "type"]
          @$(".im-list-#{field}").val("")
      @initTags()

    create: ->
      {query, name, type, description} = @listOptions.toJSON()
      tags = @tags.map (t) -> t.get "item"

      unless name and /\w/.test name
        return @setError '.im-list-name', intermine.messages.actions.ListNameEmpty
          
      if illegals = name.match ILLEGAL_LIST_NAME_CHARS
        return @setError '.im-list-name', intermine.messages.actions.ListNameIllegal {illegals}

      listQ = query or {select: ["id"], from: type, where: {id: _(@types).keys()}}

      opts = {name, description, tags}

      @makeNewList listQ, opts

    makeNewList: (query, opts) ->
      if query.saveAsList?
        saving = query.saveAsList(opts)
        saving.done @handleSuccess
        saving.fail @handleFailure
        @stop()
      else
        @query.service.query query, (q) => @makeNewList q, opts

    handleSuccess: (list) =>
      console.log "Created a list", list
      @query.trigger "list-creation:success", list

    handleFailure: (xhr, level, message) =>
      message = (JSON.parse xhr.responseText).error if xhr.responseText
      @query.trigger "list-creation:failure", message

    removeTag: (e) ->
      tag = $(e.target).closest('.label').find('.tag-text').text()
      @tags.remove(tag)
      @suggestedTags.add(tag)
      $('.tooltip').remove() # Fix for tooltips that outstay their welcome

    acceptTag: (e) ->
      console.log "Accepting", e
      tag = $(e.target).closest('.label').find('.tag-text').text()
      $('.tooltip').remove() # Fix for tooltips that outstay their welcome
      @suggestedTags.remove(tag)
      @tags.add(tag)

    updateTagBox: =>
      box = @$ '.im-list-tags.choices'
      box.empty()
      @tags.each (t) ->
          $li = $ """
              <li title="#{ t.escape "item" }">
                  <span class="label label-warning">
                      <i class="icon-tag icon-white"></i>
                      <span class="tag-text">#{ t.escape "item" }</span>
                      <a href="#">
                          <i class="icon-remove-circle icon-white remove-tag"></i>
                      </a>
                  </span>
              </li>
          """
          $li.tooltip(placement: "top").appendTo box
      box.append """<div style="clear:both"></div>"""

      box = @$ '.im-list-tags.suggestions'
      box.empty()
      @suggestedTags.each (t) ->
          $li = $ """
              <li title="This tag is a suggestion. Click the 'ok' sign to add it">
                  <span class="label">
                      <i class="icon-tag icon-white"></i>
                      <span class="tag-text">#{ t.escape "item" }</span>
                      <a href="#" class="accept-tag">
                          <i class="icon-ok-circle icon-white"></i>
                      </a>
                  </span>
              </li>
          """
          $li.tooltip(placement: "top").appendTo box
      box.append """<div style="clear:both"></div>"""


    addTag: (e) ->
      e.preventDefault()
      tagAdder = @$ '.im-available-tags'
      @tags.add(tagAdder.val())
      tagAdder.val("")
      tagAdder.next().attr(disabled: true)

    rendered: false

    render: ->
      super()
      @updateTagBox()

      tagAdder = @$ '.im-available-tags'
      @$('a').button()
      @getLists().done (ls) -> tagAdder.typeahead
        source: (_.reduce ls, ((a, l) -> _.union a, l.tags), [])
        items: 10
        matcher: (item) ->
          return true unless @query # Show all options on focus
          @constructor::matcher.call(@, item)
      tagAdder.keyup (e) =>
        @$('.im-confirm-tag').attr("disabled", false)
        if e.which is 13 # <ENTER>
          @addTag(e)

      if @canTag? and not @canTag
          @hideTagOptions()

      @rendered = true

      this

  scope 'intermine.actions.lists', {ListCreator}

  ListCreator
