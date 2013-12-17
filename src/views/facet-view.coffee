InterMineView = require './intermine-view'

{utils}  = require 'imjs'

FACET_TITLE = """
    <dt>
      <i class="icon-chevron-right"></i>
      <span class="im-facet-title"></span>
      &nbsp;<span class="im-facet-count"></span>
    </dt>
"""

class exports.FacetView extends InterMineView

    tagName: "dl"

    initialize: (@query, @facet, @limit, @noTitle) ->
        @query.on "change:constraints", @render
        @query.on "filter:summary", @render

    events: ->
      "click dt": "toggle"

    toggle: ->
        @$('.im-facet').slideToggle()
        @$('dt i').first().toggleClass 'icon-chevron-right icon-chevron-down'
        @trigger 'toggled', @

    close: ->
        @$('.im-facet').slideUp()
        @$('dt i').removeClass('icon-chevron-down').addClass('icon-chevron-right')
        @trigger 'close', @

    render: =>
        unless @noTitle
          @$el.prepend FACET_TITLE
          utils.success(@facet.title).then (title) => @$('.im-facet-title').text title
        this

