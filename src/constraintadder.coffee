namespace "intermine.query", (public) ->

    pos = (substr) -> _.memoize (str) -> str.toLowerCase().indexOf substr
    pathLen = _.memoize (str) -> str.split(".").length

    public PATH_LEN_SORTER = (items) ->
        getPos = pos @query.toLowerCase()
        items.sort (a, b) ->
            if a is b
                0
            else
                getPos(a) - getPos(b) || pathLen(a) - pathLen(b) || if a < b then -1 else 1
        return items

    public PATH_MATCHER = (item) ->
        lci = item.toLowerCase()
        terms = (term for term in @query.toLowerCase().split(/\s+/) when term)
        item and _.all terms, (t) -> lci.match(t)

    public PATH_HIGHLIGHTER = (item) ->
        terms = @query.toLowerCase().split(/\s+/)
        for term in terms when term
            item = item.replace new RegExp(term, "gi"), (match) -> "<>#{ match }</>"
        item.replace(/>/g, "strong>")

    CONSTRAINT_ADDER_HTML = """
        <input type="text" placeholder="Add a new filter" class="im-constraint-adder span9">
        <button disabled class="btn span2" type="submit">
            Filter
        </button>
    """

    public class ConstraintAdder extends Backbone.View

        tagName: "form"
        className: "form im-constraint-adder row-fluid im-constraint"

        initialize: (@query) ->
            @initPaths()
            @query.on "cancel:add-constraint", =>
                @$('input').show()
                @$('button[type="submit"]').show()

        initPaths: -> @paths = @query.getPossiblePaths(depth = 3)

        events:
            'submit': 'handleSubmission'
            'focus input': 'activateSearch'
            'blur input': 'leaveSearch'
            'click': 'handleClick'

        handleKeyup: (e) -> $(e.target).next().attr disabled: false

        activateSearch: (e) ->
            $(e.target).val(@query.root).keyup()

        leaveSearch: (e) ->
            emptySearchBox = ->
                $(e.target).val("")
                $(e.target).next().attr disabled: true
            _.delay emptySearchBox, 7000

        handleClick: (e) ->
            e.preventDefault()
            e.stopPropagation()
            if $(e.target).is 'button[type="submit"]'
                @handleSubmission(e)

        handleSubmission: (e) ->
            e.preventDefault()
            e.stopPropagation()
            @$('input').hide()
            @$('button[type="submit"]').hide()
            con =
                path: @$('input').val()

            ac = new intermine.query.NewConstraint(@query, con)
            ac.render().$el.appendTo @el

        initTypeahead: ->
            @$('input').keyup(@handleKeyup).typeahead
                source: @paths
                items: 15
                sorter: PATH_LEN_SORTER
                matcher: PATH_MATCHER
                highlighter: PATH_HIGHLIGHTER
            this

        render: ->
            @$el.append CONSTRAINT_ADDER_HTML
            @initTypeahead()

