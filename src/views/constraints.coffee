InterMineView = require './intermine-view'

class exports.Constraints extends InterMineView

    className: "im-constraints"

    initialize: (@query) ->
        @query.on "change:constraints", @render

    getConstraints: -> @query.constraints

    getConAdder: -> new intermine.query.ConstraintAdder(@query)

    render: =>
        cons = @getConstraints()
        msgs = intermine.messages.filters

        @$el.empty()
        @$el.append(@make "h3", {}, msgs.Heading)
        conBox = $ """<div class="#{ intermine.css.FilterBoxClass }">"""
        conBox.appendTo(@el)
          .append(@make "p",  {class: 'well-help'}, if cons.length then msgs.EditOrRemove else msgs.None)
          .append(ul = @make "ul", {})

        for c in cons then do (c) =>
            con = new intermine.query.ActiveConstraint(@query, c)
            con.render().$el.appendTo $ ul

        @getConAdder()?.render().$el.appendTo @el

        this

    events:
        click: (e) -> e.stopPropagation()
