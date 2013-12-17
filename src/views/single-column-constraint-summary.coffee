{SingleColumnConstraints} = require './single-column-constraints'

class exports.SingleColumnConstraintsSummary extends SingleColumnConstraints
    getConAdder: ->

    render: ->
        super()
        cons = @getConstraints()
        if cons.length < 1
            @undelegateEvents()
            @$el.hide()
        this
