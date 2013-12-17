Backbone = require 'backbone'

{Constraints} = require '../constraints'
{Facets} = require '../facets'

class exports.Filters extends Backbone.View
    className: "im-query-filters"

    initialize: (@query) ->

    render: ->
        constraints = new Constraints(@query)
        constraints.render().$el.appendTo @el

        facets = new Facets(@query)
        facets.render().$el.appendTo @el

        this
