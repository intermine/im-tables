{getMessage}      = require '../messages'
{ConstraintAdder} = require './constraint-adder'

class exports.SingleConstraintAdder extends ConstraintAdder

    initialize: (query, @view) ->
        super(query)
        @query.on 'cancel:add-constraint', => # Reset add button to appropriate state.
            @$('.btn-primary').toggle @getTreeRoot().isAttribute()

    initPaths: -> [@view]

    getTreeRoot: () -> @query.getPathInfo(@view)

    render: ->
        super()
        @$('input').remove()
        root = @getTreeRoot()
        console.log @view
        if root.isAttribute()
            @chosen = root
            @$('button.btn-primary').text(getMessage 'filters.DefineNew').attr disabled: false
            @$('button.btn-chooser').remove()
        this

