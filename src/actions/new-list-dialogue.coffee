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
      @listOptions = new Backbone.Model
      @tags.on "add", @updateTagBox
      @suggestedTags.on "add", @updateTagBox
      @tags.on "remove", @updateTagBox

      @initTags()

    hideTagOptions: () -> @$('.im-tag-options').hide()

    newCommonType: (type) ->
      super(type)
      now = new Date()
      dateStr = "#{ now }".replace(/\s\d\d:\d\d:\d\d\s.*$/, '')
      
      text = "#{ type } list - #{ dateStr }"
      
      $target = @$ '.im-list-name'

      if @usingDefaultName
        copyNo = 1
        textBase = text
        $target.val text
        @query.service.fetchLists (ls) =>

          for l in _.sortBy(ls, (l) -> l.name)
            if l.name is text
              text = "#{textBase} (#{ copyNo++ })"
              $target.val text

          @usingDefaultName = true
        cd = @query.model.classes[type]
        # The following is much too specific and should be configurable...
        # TODO: refactor this out into general logic 
        # and make it work with selections for all objects.
        if cd.fields['organism']?
            ids = _.keys(@types)
            if ids?.length
                oq =
                    select: 'organism.shortName',
                    from: type,
                    where:
                        id: _.keys(@types)

                @query.service.query oq, (orgQuery) ->
                    orgQuery.count (c) ->
                        if c is 1
                            orgQuery.rows (rs) ->
                                newVal = "#{ type } list for #{ rs[0][0] } - #{ dateStr }"
                                textBase = newVal
                                $target.val newVal


        @$('.im-list-type').val(type)

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

    rollUpNext: (e) ->
      $(e.target).next().slideToggle()
      $(e.target).find("i").toggleClass("icon-chevron-right icon-chevron-down")

    reset: ->
      for field in ["name", "desc", "type"]
          @$(".im-list-#{field}").val("")
      @initTags()

    create: (q) ->
      $nameInput = @$ '.im-list-name'
      newListName = $nameInput.val()
      newListDesc = @$('.im-list-desc').val()
      newListType = @$('.im-list-type').val()
      newListTags = @tags.map (t) -> t.get "item"
      if not newListName
          $nameInput.next().text """
              A list requires a name. Please enter one.
          """
          $nameInput.parent().addClass "error"
          
      else if illegals = newListName.match ILLEGAL_LIST_NAME_CHARS
          $nameInput.next().text """
              This name contains illegal characters (#{ illegals }). Please remove them
          """
          $nameInput.parent().addClass "error"
      else
          listQ = (q or {select: ["id"], from: newListType, where: {id: _(@types).keys()}})
          opts =
              name: newListName
              description: newListDesc
              tags: newListTags

          @makeNewList listQ, opts
          @$('.btn-primary').unbind('click')

    makeNewList: (query, opts) =>
      if query.service?
          query.saveAsList(opts, @handleSuccess).fail(@handleFailure)
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
      @query.service.fetchLists (ls) -> tagAdder.typeahead
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
