do ->

   # Model for representing something with one major field
    class Item extends Backbone.Model

        initialize: (item) ->
            @set "item", item

    # Class for representing a collection of items, which must be unique.
    class UniqItems extends Backbone.Collection
        model: Item

        # Add items is they are non null, not empty strings, and not already in the collection.
        add: (items, opts) ->
            items = if _(items).isArray() then items else [items]
            for item in items when item? and "" isnt item
                super(new Item(item, opts)) unless (@any (i) -> i.get("item") is item)
                
        remove: (item, opts) ->
            delenda = @filter (i) -> i.get("item") is item
            super(delenda, opts)

    ILLEGAL_LIST_NAME_CHARS = /[^\w\s\(\):+\.-]/g


    class Actions extends Backbone.View

        className: "im-query-actions row-fluid"
        tagName: "ul"

        initialize: (@query) ->

        actionClasses: -> [ListManager, CodeGenerator, Exporters]
        extraClass: "im-action"
        render: ->
            for cls in @actionClasses()
                action = new cls(@query)
                action.render().$el.addClass(@extraClass).appendTo @el

            this

    class ActionBar extends Actions
        extraClass: "im-action"
        actionClasses: ->
            [ListManager, CodeGenerator, intermine.query.export.ExportDialogue] #Exporters]


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

        events:
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


    class ListAppender extends ListDialogue

        html: """
            <div class="modal fade">
                <div class="modal-header">
                    <a class="close btn-cancel">close</a>
                    <h2>Add Items To Existing List</h2>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal form">
                        <fieldset class="control-group">
                            <label>
                                Add
                                <span class="im-item-count"></span>
                                <span class="im-item-type"></span>
                                to:
                                <select class="im-receiving-list">
                                    <option value=""><i>Select a list</i></option>
                                </select>
                            </label>
                            <span class="help-inline"></span>
                        </fieldset>
                    </form>
                    <div class="alert alert-error im-none-compatible-error">
                        <b>Sorry!</b> You don't have access to any compatible lists.
                    </div>
                    <div class="alert alert-info im-selection-instruction">
                        <b>Get started!</b> Choose items from the table below.
                        You can move this dialogue around by dragging it, if you 
                        need access to a column it is covering up.
                    </div>
                </div>
                <div class="modal-footer">
                    <div class="btn-group">
                        <button disabled class="btn btn-primary">Add to list</button>
                        <button class="btn btn-cancel">Cancel</button>
                    </div>
                </div>
            </div>
        """

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

    openWindowWithPost = (uri, name, params) ->

        form = $ """<form method="POST" action="#{ uri }" target="#{ name }#{ new Date().getTime() }">"""

        for k, v of params
            input = $("""<input name="#{ k }" type="hidden">""")
            form.append(input)
            input.val(v)
        form.appendTo 'body'
        w = window.open("someNonExistantPathToSomeWhere", name)
        form.submit()
        form.remove()
        w.close()

    CODE_GEN_LANGS = [
        {name: "Perl", extension: "pl"},
        {name: "Python", extension: "py"},
        {name: "Ruby", extension: "rb"},
        {name: "Java", extension: "java"},
        {name: "JavaScript", extension: "js"}
        {name: "XML", extension: "xml"}
    ]

    class CodeGenerator extends Backbone.View
        tagName: "li"
        className: "im-code-gen"

        html: _.template("""
            <div class="btn-group">
                <a class="btn btn-action" href="#">
                    <i class="#{ intermine.icons.Script }"></i>
                    <span class="im-only-widescreen">Get</span>
                    <span class="im-code-lang"></span>
                    Code
                </a>
                <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
                    <span class="caret"></span>
                </a>
                <ul class="dropdown-menu">
                    <% _(langs).each(function(lang) { %>
                      <li>
                        <a href="#" data-lang="<%= lang.extension %>">
                           <i class="icon-<%= lang.extension %>"></i>
                           <%= lang.name %>
                        </a>
                      </li>
                    <% }); %>
                </ul>
            </div>
            <div class="modal fade">
                <div class="modal-header">
                    <a class="close" data-dismiss="modal">close</a>
                    <h3>Generated <span class="im-code-lang"></span> Code</h3>
                </div>
                <div class="modal-body">
                    <pre class="im-generated-code prettyprint linenums">
                    </pre>
                </div>
                <div class="modal-footer">
                    <a href="#" class="btn btn-save"><i class="icon-file"></i>Save</a>
                    <!-- <button href="#" class="btn im-show-comments" data-toggle="button">Show Comments</button> -->
                    <a href="#" data-dismiss="modal" class="btn">Close</a>
                </div>
            </div>
        """, {langs: CODE_GEN_LANGS})

        initialize: (@query) ->
          @model = new Backbone.Model
          @model.on 'set:lang', @displayLang

        render: =>
            @$el.append @html
            this

        events:
            'click .im-show-comments': 'showComments'
            'click .dropdown-menu a': 'setLang'
            'click .btn-action': 'doMainAction'

        showComments: (e) =>
            if $(e.target).is '.active'
                @compact()
            else
                @expand()

        # Rather naive (but generally effective) method of
        # prettifying the otherwise compressed XML.
        breakAndIndent = (xml) ->
          lines = xml.split /></
          indentLevel = 1
          buffer = []
          for line in lines
            unless />$/.test line
              line = line + '>'
            unless /^</.test line
              line = '<' + line

            isClosing = /^<\/\w+\s*>/.test(line)
            isOneLiner = /\/>$/.test(line) or (not isClosing and /<\/\w+>$/.test(line))
            isOpening = not (isOneLiner or isClosing)

            indentLevel-- if isClosing

            indent = new Array(indentLevel).join('  ')
            buffer.push indent + line
            
            indentLevel++ if isOpening

          return buffer.join("\n")

        alreadyDone = jQuery.Deferred -> @resolve(true)

        setLang: (e) ->
          $t = $ e.target
          @model.set {lang: $t.data('lang') or @model.get('lang')}, {silent: true}
          @model.trigger 'set:lang'

        displayLang: =>
          $m    = @$ '.modal'
          lang  = @model.get('lang')

          ext   = if lang is 'js'  then 'html' else lang
          href  = if lang is 'xml' then '#'    else @query.getCodeURI lang
          code  = if lang is 'xml' then breakAndIndent(@query.toXML()) else @query.fetchCode lang
          ready = if prettyPrintOne? then alreadyDone else intermine.cdn.load 'prettify'

          @$('a .im-code-lang').text lang
          @$('.modal h3 .im-code-lang').text lang
          @$('.modal .btn-save').attr href: @query.getCodeURI @lang

          jQuery.when(code, ready).then (code) ->
            formatted = prettyPrintOne(_.escape(code), ext)
            $m.find('pre').html formatted
            $m.modal 'show'

        doMainAction: (e) =>
            if @model.has('lang') then @displayLang() else $(e.target).next().dropdown 'toggle'

        compact: =>
            $m = @$ '.modal'
            $m.find('span.com').closest('li').slideUp()
            $m.find('.linenums li').filter(-> $(@).text().replace(/\s+/g, "") is "").slideUp()

        expand: =>
            $m = @$ '.modal'
            $m.find('linenums li').slideDown()

    class ListCreator extends ListDialogue

        html: """
            <div class="modal fade im-list-creation-dialogue">
                <div class="modal-header">
                    <a class="close btn-cancel">close</a>
                    <h2>List Details</h2>
                </div>
                <div class="modal-body">
                    <form class="form form-horizontal">
                        <p class="im-list-summary"></p>
                        <fieldset class="control-group">
                            <label>Name</label>
                            <input class="im-list-name input-xlarge" type="text" placeholder="required identifier">
                            <span class="help-inline"></span>
                        </fieldset>
                        <fieldset class="control-group">
                            <label>Description</label>
                            <input class="im-list-desc input-xlarge" type="text" placeholder="an optional description" >
                        </fieldset>
                        <fieldset class="control-group im-tag-options">
                            <label>Add Tags</label>
                            <input type="text" class="im-available-tags input-medium" placeholder="categorize your list">
                            <button class="btn im-confirm-tag" disabled>Add</button>
                            <ul class="im-list-tags choices well">
                                <div style="clear:both"></div>
                            </ul>
                            <h5><i class="icon-chevron-down"></i>Suggested Tags</h5>
                            <ul class="im-list-tags suggestions well">
                                <div style="clear:both"></div>
                            </ul>
                        </fieldset>
                        <input type="hidden" class="im-list-type">
                    </form>
                    <div class="alert alert-info im-selection-instruction">
                        <b>Get started!</b> Choose items from the table below.
                        You can move this dialogue around by dragging it, if you 
                        need access to a column it is covering up.
                    </div>
                </div>
                <div class="modal-footer">
                    <div class="btn-group">
                        <button class="btn btn-primary">Create</button>
                        <button class="btn btn-cancel">Cancel</button>
                        <button class="btn btn-reset">Reset</button>
                    </div>
                </div>
            </div>
        """

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
        
        events: _.extend({}, ListDialogue::events, {
            'click .remove-tag': 'removeTag'
            'click .accept-tag': 'acceptTag'
            'click .im-confirm-tag': 'addTag'
            'click .btn-reset': 'reset'
            'click .control-group h5': 'rollUpNext'})

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
            @query.service.fetchLists (ls) ->
                tags = _(ls).reduce( ((a, l) -> _.union(a, l.tags)), [])
                tagAdder.typeahead
                    source: tags
                    items: 10
                    matcher: (item) ->
                        return true unless @query # Show all options on focus
                        pattern = new RegExp @query, "i"
                        return pattern.test item
            tagAdder.keyup (e) =>
                @$('.im-confirm-tag').attr("disabled", false)
                if e.which is 13 # <ENTER>
                    @addTag(e)

            if @canTag? and not @canTag
                @hideTagOptions()

            @rendered = true

            this

    class ListManager extends Backbone.View
        tagName: "li"
        className: "im-list-management dropdown"

        initialize: (@query) ->
            @query.on "change:views", @updateTypeOptions
            @query.on "change:constraints", @updateTypeOptions
            @action = ListManager.actions.create

        html: """
            <a href="#" class="btn" data-toggle="dropdown">
                <i class="icon-list-alt"></i>
                <span class="im-only-widescreen">Create / Add to</span>
                List
                <b class="caret"></b>
            </a>
            <ul class="dropdown-menu im-type-options pull-right">
                <div class="btn-group" data-toggle="buttons-radio">
                    <button class="btn active im-list-action-chooser" data-action="create">
                        Create New List
                    </button>
                    <button class="btn im-list-action-chooser" data-action="append">
                        Add to Existing List
                    </button>
                </div>
            </ul>
        """

        events:
            'click .btn-group > .im-list-action-chooser': 'changeAction'
            'click .im-pick-and-choose': 'startPicking'

        @actions:
            create: ListCreator
            append: ListAppender

        changeAction: (e) =>
            e.stopPropagation()
            e.preventDefault()
            $t = $(e.target).button "toggle"
            @action = ListManager.actions[ $t.data 'action' ]

        openDialogue: (type, q) ->
            dialog = new @action(@query)
            dialog.render().$el.appendTo @el
            dialog.openDialogue type, q

        startPicking: ->
            dialog = new @action(@query)
            dialog.render().$el.appendTo @el
            dialog.startPicking()

        updateTypeOptions: =>
            ul = @$ '.im-type-options'
            ul.find("li").remove()

            viewNodes = @query.getViewNodes()

            for node in viewNodes then do (node) =>
                li = $ """<li></li>"""
                ul.append li
                countQuery = @query.clone()
                try
                    countQuery.select [node.append("id").toPathString()]
                catch err
                    console.error(err)
                    return

                unselected = viewNodes.filter (n) -> n isnt node

                for missingNode in unselected
                    ns = missingNode.toPathString()
                    inCons = _.any @query.constraints, (c) -> c.path.substring(0, ns.length) is ns
                    unless (inCons or @query.isOuterJoined(missingNode))
                        countQuery.addConstraint( [missingNode.append("id"), "IS NOT NULL"] )

                countQuery.orderBy []

                li.click => @openDialogue(node.getType().name, countQuery)

                colNos = (i + 1 for v, i in @query.views when @query.getPathInfo(v).getParent().toPathString() is node.toPathString())

                li.mouseover => @query.trigger "start:highlight:node", node
                li.mouseout => @query.trigger "stop:highlight"

                countQuery.count (n) ->
                    return li.remove() if n < 1
                    quantifier = switch n
                        when 1 then "The"
                        when 2 then "Both"
                        else "All #{n}"
                    typeName = intermine.utils.pluralise(node.getType().name, n)
                    col = intermine.utils.pluralise("column", colNos.length)
                    
                    li.append """
                        <a href="#">
                            #{quantifier} #{typeName} from #{col} #{colNos.join(", ")}
                        </a>
                    """

            ul.append """
                <li class="im-pick-and-choose">
                    <a href="#">Choose individual items from the table</a>
                </li>
            """

        render: ->
            @$el.append @html
            @updateTypeOptions()
            this

    scope "intermine.query.actions", {Actions, ActionBar, ListCreator, ListAppender}
