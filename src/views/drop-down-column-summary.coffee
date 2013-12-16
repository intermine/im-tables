Backbone = require 'backbone'

{SummaryHeading} = require './summary-heading'
{ColumnSummary} = require './column-summary'

class exports.DropDownColumnSummary extends Backbone.View
    className: "im-dropdown-summary"

    initialize: (@query, @view) ->

    remove: ->
      @heading?.remove()
      @summ?.remove()
      super()

    render: ->
        heading = new SummaryHeading(@query, @view)
        heading.render().$el.appendTo @el
        @heading = heading

        @summ = new ColumnSummary(@query, @view)
        @summ.noTitle = true
        @summ.render().$el.appendTo @el

        this

