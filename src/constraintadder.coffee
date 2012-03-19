namespace "intermine.query", (public) ->

    public PATH_LEN_SORTER = (items) ->
        _(items).sortBy (x) ->
            x.split(".").length

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
            'keyup input': 'handleKeyup'
            'focus input': 'activateSearch'
            'blur input': 'leaveSearch'
            'click': 'handleClick'

        handleKeyup: (e) ->
            console.log "KEYUP"
            $(e.target).next().attr disabled: false

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
            @$('input').typeahead
                source: @paths
                items: 15
                sorter: intermine.query.PATH_LEN_SORTER
            this

        render: ->
            @$el.append CONSTRAINT_ADDER_HTML
            @initTypeahead()

