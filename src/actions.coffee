scope "intermine.icons", {
    Script: "icon-beaker",
    Export: "icon-download-alt",
    Remove: "icon-minus-sign",
    Add: "icon-plus-sign",
    Move: "icon-reorder"
}

scope "intermine.messages.actions", {
    ExportTitle: "Download Results",
    ExportButton: "Download",
    ExportFormat: "Format",
    Cancel: "Cancel",
    Export: "Download",
    SendToGalaxy: "Send to Galaxy",
    AllRows: "All Rows",
    RowsHelp: "Uncheck this box to select a range of rows from the result set",
    AllColumns: "All Columns",
    ColumnsHelp: "Uncheck this box to select different columns for export than those in the table",
    FirstRow: "From",
    LastRow: "To",
    ColumnHeaders: "Include Column Headers",
    PossibleColumns: "Columns You Can Add",
    ExportedColumns: "Columns To Export",
    ChangeColumns: """
            You may add any of the columns in the right hand box by clicking on the
            plus sign. You may remove unwanted columns by clicking on the minus signs
            in the left hand box. Note that while adding these columns will not alter your query,
            if you remove all the attributes from an item, then you <b>may change</b> the results
            you receive.
        """,
    OuterJoinWarning: """
            This query has outer-joined collections. This means that the number of rows in 
            the table is likely to be different from the number of rows in the exported results.
            <b>You are strongly discouraged from specifying specific ranges for export</b>. If
            you do specify a certain range, please check that you did in fact get all the 
            results you wanted.
        """
}

scope "intermine.query.actions", (exporting) ->

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

    exporting class Actions extends Backbone.View

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

    exporting class ActionBar extends Actions
        extraClass: "im-action"
        actionClasses: ->
            [ListManager, CodeGenerator, ExportDialogue] #Exporters]

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
                    m = @query.service.model
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
        
        listNameChanged: -> @usingDefaultName = false

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

    class ExportDialogue extends Backbone.View
        tagName: "li"
        className: "im-export-dialogue dropdown"

        html: """
            <a class="btn im-open-dialogue" href="#">
                <i class="#{ intermine.icons.Export }"></i>
                #{ intermine.messages.actions.ExportButton }
            </a>
            <div class="modal fade">
                <div class="modal-header">
                    <a class="close btn-cancel">close</a>
                    <h2>#{ intermine.messages.actions.ExportTitle }</h2>
                </div>
                <div class="modal-body">
                    <form class="form row-fluid">
                        <label>
                            <span class="span4">
                                #{ intermine.messages.actions.ExportFormat }
                            </span>
                            <select class="im-export-format input-xlarge span8">
                            </select>
                        </label>
                        <label title="#{ intermine.messages.actions.ColumnsHelp }">
                            <span class="span4">
                                #{ intermine.messages.actions.AllColumns }
                            </span>
                            <input type="checkbox" checked class="im-all-cols span8">
                        </label>
                        <div class="im-col-options disabled">
                            <ul class="well im-cols im-can-be-exported-cols">
                                <h4>#{ intermine.messages.actions.PossibleColumns }</h4>
                            </ul>
                            <ul class="well im-cols im-exported-cols">
                                <h4>#{ intermine.messages.actions.ExportedColumns }</h4>
                            </ul>
                            <div style="clear:both;"></div>
                            <div class="alert alert-info">
                                <button class="close" data-dismiss="alert">×</button>
                                <strong>ps</strong>
                                <p>#{ intermine.messages.actions.ChangeColumns }</p>
                            </div>
                        </div>
                        <label title="#{ intermine.messages.actions.RowsHelp }">
                            <span class="span4">
                                #{ intermine.messages.actions.AllRows }
                             </span>
                            <input type="checkbox" checked class="im-all-rows span8">
                        </label>
                        <div class="form-horizontal">
                        <fieldset class="im-row-selection control-group">
                            <label class="control-label">
                                #{ intermine.messages.actions.FirstRow }
                                <input type="text" value="0" class="disabled input-mini im-first-row">
                            </label>
                            <label class="control-label">
                                #{ intermine.messages.actions.LastRow }
                                <input type="text" class="disabled input-mini im-last-row">
                            </label>
                            <div style="clear:both"></div>
                            <div class="slider im-row-range-slider"></div>
                        </fieldset>
                        </div>
                        <fieldset class="im-export-options">
                        </fieldset>
                    </form>
                </div>
                <div class="modal-footer">
                    <div class="btn-group pull-right">
                        <button class="btn btn-alt">
                            #{ intermine.messages.actions.SendToGalaxy }
                        </button>
                        <button class="btn btn-primary">
                            #{ intermine.messages.actions.Export }
                        </button>
                    </div>
                    <button class="btn btn-cancel pull-left">
                        #{ intermine.messages.actions.Cancel }
                    </button>
                </div>
            </div>
        """

        events:
            'change .im-all-cols': 'toggleColSelection'
            'change .im-all-rows': 'toggleRowSelection'
            'click a.im-open-dialogue': 'openDialogue'
            'click .btn-cancel': 'stop'
            'change .im-export-format': 'updateFormatOptions'
            'click button.btn-primary': 'export'

        export: (e) ->
            uri = @query.getExportURI @format
            uri += @getExtraOptions()
            window.open(uri)

        getExtraOptions: () ->
            ret = ""
            if @$('.im-column-headers').is ':checked'
                ret += "&columnheaders=1"
            unless @wantsAll
                start = parseInt @$('.im-first-row').val()
                end = parseInt @$('.im-last-row').val()
                ret += "&start=#{ start }"
                if end isnt @count
                    ret += "&size=#{ end - start }"
            ret

        wantsAll: true

        toggleColSelection: (e) ->
            @allCols = @$('.im-all-cols').is ':checked'
            @$('.im-col-options').toggleClass 'disabled', @allCols

        toggleRowSelection: (e) ->
            @wantsAll = @$('.im-all-rows').is ':checked'
            @$('.im-row-selection').toggle not @wantsAll
            #@$('.im-row-selection input').attr(disabled: @wantsAll).toggleClass('disabled', @wantsAll)
            #@$('.slider').slider 'option', disabled: @wantsAll

        openDialogue: (e) -> @$('.modal').modal('show')

        stop: (e) ->
            @$('.modal').modal('hide')
            @reset()

        reset: () -> # Go back to the initial state...
            @$('.im-all-cols').attr checked: true
            @$('.im-all-rows').attr checked: true
            @$('.im-export-format').val EXPORT_FORMATS[0].extension
            @exportedCols = @query.views.slice()

            @initCols()
            @toggleColSelection()
            @updateFormatOptions()

            @$('.slider').slider('destroy')
            @makeSlider()

        updateFormatOptions: (e) ->
            opts = @$('.im-export-options').empty()
            @format = @$('.im-export-format').val()
            if @format in ['tab', 'csv']
                opts.append """
                    <label>
                        <span class="span4">
                            #{ intermine.messages.actions.ColumnHeaders }
                        </span>
                        <input type="checkbox" class="im-column-headers span8">
                    </label>
                """

        initialize: (@query) ->

        initCols: () ->
            @$('.im-cols li').remove()

            cols = @$ '.im-exported-cols'
            for v in @exportedCols
                p = @query.getPathInfo(v)
                li = $ """<li></li>"""
                li.appendTo cols
                do (p, li) =>
                    p.getDisplayName (name) =>
                        li.append """
                            <div class="label label-success">
                                <i class="#{intermine.icons.Move} im-move pull-right"></i>
                                <a href="#"><i class="#{intermine.icons.Remove}"></i></a>
                                #{ name }
                            </div>
                        """
                        li.find('a').click () =>
                            @exportedCols = _.without @exportedCols, p.toString()
                            maybes.addClass('active')
                            _.delay (() -> maybes.removeClass('active')), 1000
                            @initCols()

            cols.sortable()

            maybes = @$ '.im-can-be-exported-cols'
            for n in @query.getQueryNodes()
                for cn in n.getChildNodes() when cn.isAttribute() and cn.toString() not in @exportedCols
                    li = $ """<li></li>"""
                    li.appendTo maybes
                    do (cn, li) =>
                        cn.getDisplayName (name) =>
                            li.append """
                                <div class="label">
                                    <a href="#"><i class="#{intermine.icons.Add}"></i></a>
                                    #{ name }
                                </div>
                            """
                            li.find('a').click (e) =>
                                @exportedCols.push cn.toString()
                                cols.addClass('active')
                                _.delay (() -> cols.removeClass('active')), 1000
                                @initCols()

        render: () ->

            @$el.append @html
            select = @$ '.im-export-format'

            for format in EXPORT_FORMATS
                select.append """<option value="#{format.extension}">#{format.name}</option>"""

            @exportedCols = @query.views.slice()

            @initCols()
            @toggleColSelection()
            @updateFormatOptions()

            if _.any(@query.joins, (s, p) => (s is 'OUTER') and @query.canHaveMultipleValues(p))
                @$('.im-row-selection').append """
                        <div class="alert alert-warning">
                            <button class="close" data-dismiss="alert">×</button>
                            <strong>NB</strong>
                            #{ intermine.messages.actions.OuterJoinWarning }
                        </div>
                    """

            @makeSlider()

            @$el.find('.modal').hide()

            this

        makeSlider: () ->
            @query.count (c) =>
                @count = c
                @$('.im-last-row').val c
                sl = @$('.slider').slider
                    range: true,
                    min: 0,
                    max: c,
                    values: [0, c],
                    step: 1,
                    slide: (e, ui)  =>
                        @$('.im-first-row').val ui.values[0]
                        @$('.im-last-row').val ui.values[1]
                @toggleRowSelection()


    exporting class ListAppender extends ListDialogue

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
                    @query.trigger "list-update:success", updatedList, updatedList.size - parseInt(targetSize)
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

                @$('.im-receiving-list').append(ls.filter( (l) -> !l.hasTag("im:public")).map toOpt)
                @onlyShowCompatibleOptions()
            this

        startPicking: ->
            super()
            @$('.im-none-compatible-error').hide()

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
        {name: "XML", extension: "xml"},
        {name: "JSON", extension: "json"},
    ]

    BIO_FORMATS = [
        {name: "UCSC-BED", extension: "bed"},
        {name: "FASTA", extension: "fasta"},
        {name: "GFF3", extension: "gff3"}
    ]


        

    #
    #    galaxy: (uri) ->
    #        lists = (c.value for c in @query.constraints when c.op is "IN")
    #        intermine.utils.getOrganisms @query, (orgs) =>
    #            req =
    #                "tool_id": "flymine"
    #                "organism": orgs.join(", ")
    #                "info": """
    #                    #{ @query.root } data from #{ @query.service.root } 
    #                    Uploaded from #{ window.location.toString().replace(/\?.*/, "") }.
    #                    #{ if lists.length then ' source: ' + lists.join(",") else "" }
    #                   #{ if orgs.length then ' organisms: ' else ""}#{orgs.join(",")} 
    #                """
    #                "URL": uri
    #                "name": "#{ if orgs.length is 1 then orgs[0] + ' ' else ""}#{ @query.root } data"
    #                "data_type": if @format is "tab" then "tabular" else @format
    #
    #            openWindowWithPost "http://main.g2.bx.psu.edu/tool_runner", "Upload", req
    #

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
                <a class="btn dropdown-toggle" data-toggle="dropdown" href="#" style="height: 18px">
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
            $m.find('h3 .im-code-lang').text @lang
            @$('a .im-code-lang').text @lang
            if @lang is 'xml'
                xml = @query.toXML().replace(/></g, ">\n<")
                $m.find('pre').text xml
                $m.modal 'show'
                prettyPrint @compact
            else
                $m.find('.btn-save').attr href: @query.getCodeURI @lang
                @query.fetchCode @lang, (code) =>
                    $m.find('pre').text code
                    $m.modal 'show'
                    prettyPrint @compact

        doMainAction: (e) =>
            if @lang then @getAndShowCode(e) else $(e.target).next().dropdown 'toggle'

        compact: =>
            $m = @$ '.modal'
            $m.find('span.com').closest('li').slideUp()
            $m.find('.linenums li').filter(-> $(@).text().replace(/\s+/g, "") is "").slideUp()

        expand: =>
            $m = @$ '.modal'
            $m.find('linenums li').slideDown()

    exporting class ListCreator extends ListDialogue

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
            @tags  = new UniqItems()
            @suggestedTags = new UniqItems()
            @tags.on "add", @updateTagBox
            @tags.on "remove", @updateTagBox

            @initTags()

        newCommonType: (type) ->
            super(type)
            text = "List of #{intermine.utils.pluralise(type)} (#{new Date()})"
            $target = @$ '.im-list-name'
            if @usingDefaultName
                $target.val text
                @usingDefaultName = true

            @$('.im-list-type').val(type)

        openDialogue: (type, q) ->
            super(type, q)
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
                else if c.op is "<"
                    @suggestedTags.add "#{title} below #{c.value}"
                else if c.op is ">"
                    @suggestedTags.add "#{title} above #{c.value}"
                else if c.type
                    @suggestedTags.add "#{title} is a #{c.type}"
                else
                    @suggestedTags.add "#{title} #{c.op} #{c.value or c.values}"
            @updateTagBox()
        
        events: _.extend({}, ListDialogue::events, {
            'click .label .remove-tag': 'removeTag'
            'click .label .accept-tag': 'acceptTag'
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

            this

    class ListManager extends Backbone.View
        tagName: "li"
        className: "im-list-management dropdown"

        initialize: (@query) ->
            @query.on "change:views", @updateTypeOptions
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

            for node in @query.getViewNodes() then do (node) =>
                li = $ """<li></li>"""
                ul.append li
                countQuery = @query.clone()
                countQuery.select [node.append("id").toPathString()]
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
