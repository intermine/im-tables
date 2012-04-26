scope "intermine.query.columns", (exporting) ->

    exporting class Columns extends Backbone.View
        className: "im-query-columns"

        initialize: (@query) ->

        render: ->
            for cls in [ColumnAdder, CurrentColumns] then do (cls) =>
                inst = new cls(@query)
                @$el.append inst.render().el

            this

    class CurrentColumns extends Backbone.View
        className: "node-remover" # TODO- change this to be a more descriptive, scoped class name
        tagName: "dl"

        initialize: (@query) ->

        render: ->
            cd = @query.service.model.classes[@query.root]
            rootSel = new Selectable(@query, cd)
            rootSel.render().$el.appendTo @el

            subnodes = _({}).extend cd.references, cd.collections

            _(subnodes).chain()
                    .values()
                    .sortBy((f) -> f.name)
                    .each (f) =>
                        type = @query.getPathInfo(f).getEndClass()
                        sel = new Selectable(@query, type, f)
                        sel.render().$el.appendTo @el

            this

    exporting class ColumnAdder extends intermine.query.ConstraintAdder
        className: "form node-adder row-fluid"

        handleSubmission: (e) =>
            e.preventDefault()
            e.stopPropagation()
            newPath = @$('input').val()
            @query.addToSelect newPath

        render: ->
            input = @make "input",
                type: "text",
                class: "span12"
                placeholder: "Add a column..."
            @$el.append input
            @initTypeahead()

    JOIN_TOGGLE_HTML = _.template """
        <form class="form-inline pull-right im-join">
        <div class="btn-group" data-toggle="buttons-radio">
            <button data-style="INNER" class="btn btn-small <% print(outer ? "" : "active") %>">
            Required
            </button>
            <button data-style="OUTER" class="btn btn-small <% print(outer ? "active" : "") %>">
            Optional
            </button>
        </div></form>
    """

    ATTR_HTML = _.template """
        <input type="checkbox" 
            data-path="<%= path %>"
            <% inQuery ? print("checked") : "" %> >
        <span class="im-view-option">
            <%= name %> (<% print(type.replace("java.lang.", "")) %>)
        </span>
    """


    class Selectable extends Backbone.View
        tagName: "dl"
        className: "im-selectable-node"

        initialize: (@query, @table, @field) ->
            @path = @query.root + (if @field then ".#{@field.name}" else "")
            @query.on "change:views", @setCheckBoxState

        events:
            'click dt': 'toggleFields'
            'change input[type="checkbox"]': 'changeView'

        toggleFields: (e) ->
            @$('dd').slideToggle()

        changeView: (e) ->
            $t = $(e.target)
            path = $t.data "path"
            if $t.attr "checked"
                @query.addToSelect path
            else
                @query.removeFromSelect path

        setCheckBoxState: (e) =>
            @$('dd input').each (i, cbx) =>
                $cbx = $(cbx)
                path = $cbx.data "path"
                $cbx.attr checked: @query.hasView path

        render: =>
            @$el.empty()
            title = @make "h4", {}, (@field?.name or @table.name)
            dt = @make "dt", {class: "im-column-group"}, title
            @$el.append dt
            isInView = _(@query.views).any (v) -> @path is v.substring(0, v.lastIndexOf("."))
            icon = if isInView then "minus" else "plus"
            $("""<i class="icon-#{icon}-sign"></i>""")
            .css({cursor: "pointer"})
            .appendTo(title)

            # Add join controls
            if isInView and @path isnt @query.root
                $( JOIN_TOGGLE_HTML({outer: @query.isOuterJoin(@path)}) )
                .submit (e) -> e.preventDefault()
                .css "display", "inline-block"
                .appendTo title
                .find ".btn"
                .click (e) =>
                    e.stopPropagation()
                    style = $(e.target).data "style"
                    @query.setJoinStyle @path, style
                    .button()

            for name, attr of @table.attributes then do (attr) => @addAttribute attr

            this

        addAttribute: (a) ->
            if a.name isnt "id"
                dd = @make "dd"
                p = "#{ @path }.#{ a.name }"
                ctx =
                    path: p
                    inQuery: p in @query.views
                _(ctx).extend a
                $(dd).append(ATTR_HTML(ctx))
                    .appendTo(@el)

