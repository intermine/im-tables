Backbone  = require 'backbone'
intermine = require 'imjs'

options = require '../options'

{NumericFacet} = require './numeric-facet'
{FrequencyFacet} = require './frequency-facet'

# A bit of a nothing class - should be removed and replaced
# with a factory function. TODO.
class exports.ColumnSummary extends Backbone.View
    tagName: 'div'
    className: "im-column-summary"
    initialize: (@query, facet) ->
        @state = new Backbone.Model({open: false})
        if facet.path
          @facet = facet
        else
          fp = @query.getPathInfo facet
          @facet =
            path: fp
            title: fp.getDisplayName().then (name) => name.replace(/^[^>]+>\s*/, '')
            ignoreTitle: true

    render: =>
        attrType = @facet.path.getType()
        clazz = if attrType in intermine.Model.NUMERIC_TYPES
          NumericFacet
        else
          FrequencyFacet
        initialLimit = options.INITIAL_SUMMARY_ROWS
        @fac = new clazz(@query, @facet, initialLimit, @noTitle)
        @$el.append @fac.el
        @fac.render()
        @fac.on 'ready', => @trigger 'ready', @
        @fac.on 'toggled', => @state.set open: !@state.get('open')
        @fac.on 'closed', => @state.set open: false
        @trigger 'rendered', @
        this

    toggle: -> @fac?.toggle()

    close: -> @fac?.close()

    remove: ->
      @fac?.remove()
      super()
