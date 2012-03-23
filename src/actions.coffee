namespace "intermine.query.actions", (public) ->

   # Model for representing something with one major field
    class Item extends Backbone.Model

        initialize: (item) ->
            @set "item", item

    # Class for representing a collection of items, which must be unique.
    class UniqItems extends Backbone.Collection
        model: Item

        # Add items is they are non null, not empty strings, and not already in the collection.
        add: (items) ->
            items = if _(items).isArray() then items else [items]
            for item in items when item? and "" isnt item
                super(new Item(item)) unless (@any (i) -> i.get("item") is item)
                
        remove: (item) ->
            delenda = @filter (i) -> i.get("item") is item
            super(delenda)

    ILLEGAL_LIST_NAME_CHARS = /[^\w\s\(\):+\.-]/g

    public class Actions extends Backbone.View

        className: "im-query-actions"
        tagName: "ul"

        initialize: (@query) ->

        actionClasses: -> [ListCreator, ListAppender, CodeGenerator, Exporters]
        render: ->
            for cls in @actionClasses()
                action = new cls(@query)
                action.render().$el.addClass("im-action").appendTo @el

            this

    public class ActionBar extends Actions
        actionClasses: ->
            [ListCreator, ListAppender, CodeGenerator, Exporters, intermine.query.columns.ColumnAdder]

    class ListAppender extends Backbone.View
        tagName: "li"
        className: "im-add-to-list"

        initialize: (@query) ->
            @types = {}
            @query.on "imo:selected", (type, id, selected) =>
                if selected
                    @types[id] = type
                else
                    delete @types[id]
                types = _(@types).values()
                hasSelectedItems = !!types.length
                @$('.btn-primary').attr disabled: !hasSelectedItems
                if hasSelectedItems
                    m = @query.service.model
                    commonType = m.findCommonTypeOfMultipleClasses(types)
                    @$('form select option').each (i, elem) =>
                        $o = $(elem)
                        $o.attr disabled: commonType? and not m.findCommonTypeOf(commonType, $o.data("type"))?
                else
                    @$('form select option').each (i, elem) =>
                        $(elem).attr disabled: false

        events:
            'click .btn-activate': 'activate'
            'click .btn-cancel': 'activate'
            'click .btn-primary': 'appendToList'

        activate: (e) ->
            form = @$('form').slideToggle 90, =>
                if form.is ':visible'
                    evt = "start"
                else
                    evt = "stop"
                @query.trigger "#{evt}:list-creation"


        reset: ->
            form = @$('form').slideUp 90
            @query.trigger "stop:list-creation"
            this

        appendToList: (e) ->
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
            console.log targetSize

            listQ =
                select: ["id"]
                from: targetType
                where:
                    id: ids

            @query.service.query listQ, (q) =>
                promise = q.appendToList receiver.val(), (updatedList) =>
                    @query.trigger "list-update:success", updatedList, updatedList.size - parseInt(targetSize)
                    @fillSelect().reset()
                promise.fail (xhr, level, message) =>
                    if xhr.responseText
                        message = (JSON.parse xhr.responseText).error
                    @query.trigger "list-update:failure", message

        
        render: ->
            @$el.append """
                <a href="#" class="btn btn-activate">Add items to List</a>
                <form class="form-horizontal form">
                    <fieldset class="control-group">
                        <label>Add to:
                            <select class="im-receiving-list">
                                <option value=""><i>Select a list</i></option>
                            </select>
                        </label>
                        <span class="help-inline"></span>
                    </fieldset>
                    <div class="btn-group">
                        <button disabled class="btn btn-primary">Add to list</button>
                        <button class="btn btn-cancel">Cancel</button>
                    </div>
                </form>
            """

            @fillSelect()
            @query.service.fetchLists (ls) =>
                toOpt = (l) => @make "option"
                    , value: l.name, "data-type": l.type, "data-size": l.size
                    , "#{l.name} (#{l.size} #{l.type}s)"

                @$('.im-receiving-list').append("""<option value=""><i>Select a list</i></option>""")
                                        .append(ls.map toOpt)

            this

        fillSelect: ->
            @query.service.fetchLists (ls) =>
                toOpt = (l) => @make "option"
                    , value: l.name, "data-type": l.type, "data-size": l.size
                    , "#{l.name} (#{l.size} #{l.type}s)"

                @$('.im-receiving-list').empty().append(ls.map toOpt)
            this


    openWindowWithPost = (uri, name, params) ->

        form = $ """<form method="POST" action="#{ uri }" target="#{ name }">"""

        for name, value of params
            form.append """<input name="#{ name }" value="#{ value }" type="hidden">"""
        form.appendTo 'body'
        w = window.open("someNonExistantPathToSomeWhere", name)
        form.submit()
        form.remove()
        w.close()

    EXPORT_FORMATS = [
        {name: "Spreadsheet (tab separated values)", extension: "tab"},
        {name: "Spreadsheet (comma separated values)", extension: "csv"},
        null,
        {name: "XML", extension: "xml"},
        {name: "JSON", extension: "json"},
        null,
        {name: "UCSC-BED", extension: "bed"},
        {name: "FASTA", extension: "fasta"},
        {name: "GFF3", extension: "gff3"}
    ]

    class Exporters extends Backbone.View
        tagName: "li"
        className: "im-exporters"

        html: _.template("""
            <div class="btn-group">
                <a class="btn btn-action" href="#">
                    <i class="icon-download-alt"></i>
                    Export
                    <span class="im-export-format"></span>
                </a>
                <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
                    <b class="caret"></b>
                </a>
                <ul class="dropdown-menu">
                    <% _(formats).each(function(format) { %>
                        <% if (format) { %>
                            <li>
                                <a href="#" data-format="<%= format.extension %>">
                                    <%= format.name %>
                                </a>
                            </li>
                        <% } else { %>
                            <li class="divider"></li>
                        <% } %>
                    <% }); %>
                    <li>
                        <form class="form form-inline im-export-destinations">
                            <div class="btn-group" data-toggle="buttons-radio">
                                <button class="btn active" data-destination="download">
                                    Download
                                </button>
                                <button class="btn" data-destination="galaxy">
                                    Export To Galaxy
                                </button>
                            </div>
                        </form>
                    </li>
                </ul>
            </div>
            <div class="modal fade">
                <div class="modal-header">
                    <a class="close" data-dismiss="modal">close</a>
                    <h3>Export Options</h3>
                </div>
                <!-- TODO -->
                <div class="modal-body">
                    <form class="form">
                        <label>All rows
                            <input type="checkbox" checked>
                        </label>
                        <label>start
                            <input type="text">
                        </label>
                        <label>end
                            <input type="text">
                        </label>
                    </form>
                </div>
                <div class="modal-footer">
                    <a href="#" class="btn btn-save"><i class="icon-file"></i>Save</a>
                    <button href="#" class="btn im-show-comments" data-toggle="button">Show Comments</button>
                    <a href="#" data-dismiss="modal" class="btn">Close</a>
                </div>
            </div>
        """, {formats: EXPORT_FORMATS})

        initialize: (@query) ->

        render: ->
            @$el.append @html
            @destination = @$('form .btn.active').data 'destination'
            this

        events:
           'click .dropdown-menu a': 'getExport'
           'click .btn-action': 'doMainAction'
           'click .form .btn': 'changeDestination'

        changeDestination: (e) =>
            e.stopPropagation()
            e.preventDefault()
            $t = $(e.target).button 'toggle'
            @destination = $t.data 'destination'

        doMainAction: (e) =>
            if @format then @getExport(e) else $(e.target).next().dropdown 'toggle'

        getExport: (e) =>
            $t = $ e.target
            @format = $t.data('format') or @format
            @$('a .im-export-format').text "as #{@format}"
            uri = @query.getExportURI @format
            this[@destination] uri

        download: (uri) -> window.open(uri)

        galaxy: (uri) ->
            lists = (c.value for c in @query.constraints when c.op is "IN")
            intermine.utils.getOrganisms @query, (orgs) =>
                req =
                    "tool_id": "flymine"
                    "organism": orgs.join(", ")
                    "info": """
                        #{ @query.root } data from #{ @query.service.root } 
                        Uploaded from #{ window.location.toString().replace(/\?.*/, "") }.
                        #{ if lists.length then ' source: ' + lists.join(",") else "" }
                        #{ if orgs.length then ' organisms: ' else ""}#{orgs.join(",")} 
                    """
                    "URL": uri
                    "name": "#{ if orgs.length is 1 then orgs[0] + ' ' else ""}#{ @query.root } data"
                    "data_type": if @format is "tab" then "tabular" else @format

                openWindowWithPost "http://main.g2.bx.psu.edu/tool_runner", "Upload", req


    CODE_GEN_LANGS = [
        {name: "Perl", extension: "pl"},
        {name: "Python", extension: "py"},
        {name: "Ruby", extension: "rb"},
        {name: "Java", extension: "java"},
        {name: "JavaScript", extension: "js"}
    ]

    class CodeGenerator extends Backbone.View
        tagName: "li"
        className: "im-code-gen"

        html: _.template("""
            <div class="btn-group">
                <a class="btn btn-action" href="#">
                    <i class="icon-script"></i>
                    Get <span class="im-code-lang"></span> code
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
                    <button href="#" class="btn im-show-comments" data-toggle="button">Show Comments</button>
                    <a href="#" data-dismiss="modal" class="btn">Close</a>
                </div>
            </div>
        """, {langs: CODE_GEN_LANGS})

        initialize: (@query) ->

        render: =>
            @$el.append @html
            this

        events:
            'click .im-show-comments': 'showComments'
            'click .dropdown-menu a': 'getAndShowCode'
            'click .btn-action': 'doMainAction'

        showComments: (e) =>
            if $(e.target).is '.active'
                @compact()
            else
                @expand()

        getAndShowCode: (e) =>
            $t = $ e.target
            $m = @$ '.modal'

            @lang = $t.data('lang') or @lang

            $m.find('.btn-save').attr href: @query.getCodeURI @lang
            $m.find('h3 .im-code-lang').text @lang
            @$('a .im-code-lang').text @lang
            @query.fetchCode @lang, (code) =>
                $m.find('pre').text code
                $m.modal 'show'
                prettyPrint @compact

        doMainAction: (e) =>
            if @lang then @getAndShowCode(e) else $(e.target).next().dropdown 'toggle'

        compact: =>
            console.log "compacting"
            $m = @$ '.modal'
            $m.find('span.com').closest('li').slideUp()
            $m.find('.linenums li').filter(-> $(@).text().replace(/\s+/g, "") is "").slideUp()

        expand: =>
            $m = @$ '.modal'
            $m.find('linenums li').slideDown()

    class ListCreator extends Backbone.View

        tagName: "li"
        className: "im-create-list"

        html: """
            <a href="#" class="btn" data-toggle="button">
                <i class="icon-list-alt"></i>
                Create List
            </a>
            <form class="form form-horizontal">
                <p class="im-list-summary"></p>
                <fieldset class="control-group">
                    <label>Name</label>
                    <input class="im-list-name input-long" type="text" placeholder="required identifier">
                    <span class="help-inline"></span>
                </fieldset>
                <fieldset class="control-group">
                    <label>Description</label>
                    <input class="im-list-desc input-long" type="text" placeholder="an optional description" >
                </fieldset>
                <fieldset class="control-group">
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
                <div class="btn-group">
                    <button class="btn btn-primary">Create</button>
                    <button class="btn btn-cancel">Cancel</button>
                    <button class="btn btn-reset">Reset</button>
                </div>
            </form>
        """

        initialize: (@query) ->
            @model = new Backbone.Model()
            @tags = new UniqItems()
            @suggestedTags = new UniqItems()
            @types = {}

            @query.on "imo:selected", (type, id, selected) =>
                if selected
                    @types[id] = type
                else
                    delete @types[id]
                types = _(@types).values()
                commonType = @query.service.model.findCommonTypeOfMultipleClasses(types)
                text = "List of #{commonType}s (#{new Date()})"
                $target = @$ '.im-list-name'
                #unless $target.val()
                $target.val text
                @$('.im-list-type').val(types[0])

            @tags.on "add", @updateTagBox
            @tags.on "remove", @updateTagBox

            @initTags()

        initTags: ->
            @tags.reset()
            @suggestedTags.reset()
            for c in @query.constraints then do (c) =>
                title = c.title or c.path.replace(/^[^\.]+\./, "")
                if c.op is "IN"
                    @suggestedTags.add "source: #{c.value}"
                else if c.op is "="
                    @suggestedTags.add "#{title}: #{c.value}"
                else if c.type
                    @suggestedTags.add "#{title} is a #{c.type}"
                else
                    @suggestedTags.add "#{title} #{c.op} #{c.value or c.values}"
            @updateTagBox()
        
        events:
            'click .label .remove-tag': 'removeTag'
            'click .label .accept-tag': 'acceptTag'
            'click .im-confirm-tag': 'addTag'
            'click a': 'start'
            'click .btn-cancel': 'stop'
            'click .btn-primary': 'create'
            'click .btn-reset': 'reset'
            'submit form': 'ignore'
            'click .control-group h5': 'rollUpNext'

        rollUpNext: (e) ->
            $(e.target).next().slideToggle()
            $(e.target).find("i").toggleClass("icon-chevron-right icon-chevron-down")

        ignore: (e) ->
            e.preventDefault()
            e.stopPropagation()

        start: (e) ->
            @query.trigger "start:list-creation"
            @$('form').slideDown(90)

        reset: ->
            for field in ["name", "desc", "type"]
                @$(".im-list-#{field}").val("")
            @initTags()

        stop: (e) ->
            @query.trigger "stop:list-creation"
            @reset()
            @$('a').removeClass 'active'
            @$('form').slideUp 90

        create: (e) ->
            e.preventDefault()
            console.log e
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
                listQ =
                    select: ["id"]
                    from: newListType
                    where:
                        id: _(@types).keys()
                opts =
                    name: newListName
                    description: newListDesc
                    tags: newListTags
                @query.service.query listQ, (query) =>
                    promise = query.saveAsList opts, (list) =>
                        console.log "Created a list", list
                        @query.trigger "list-creation:success", list
                    promise.fail (xhr, level, message) =>
                        if xhr.responseText
                            message = (JSON.parse xhr.responseText).error
                        @query.trigger "list-creation:failure", message
                    @stop()

        removeTag: (e) ->
            tag = $(e.target).siblings('.tag-text').text()
            @tags.remove(tag)
            $('.tooltip').remove() # Fix for tooltips that outstay their welcome

        acceptTag: (e) ->
            tag = $(e.target).siblings('.tag-text').text()
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
                            <i class="icon-remove-circle icon-white remove-tag"></i>
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
                            <i class="icon-ok-circle icon-white accept-tag"></i>
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

        render: ->
            @$el.append @html
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

            this
