Backbone = require 'backbone'
_ = require 'underscore'
pluralise = require '../utils/pluralise'
numToString = require '../utils/num-to-string'

class exports.SummaryHeading extends Backbone.View

  nts = (num) -> numToString(num, ',', 3)

  initialize: (@query, @view) ->
      @query.on "got:summary:total", (path, total, got, filteredTotal) =>
        if path is @view
            available = filteredTotal ? total
            @$('.im-item-available').text nts available
            @$('.im-item-total').text(if filteredTotal? then "(filtered from #{ nts total })" else "")
            if available > got
              @$('.im-item-got').text "Showing #{ nts got } of "
            else
              @$('.im-item-got').text ''

  template: _.template """
      <h3>
          <span class="im-item-got"></span>
          <span class="im-item-available"></span>
          <span class="im-type-name"></span>
          <span class="im-attr-name"></span>
          <span class="im-item-total"></span>
      </h3>
  """

  render: ->
      @$el.append @template()

      s = @query.service
      type = @query.getPathInfo(@view).getParent().getType().name
      attr = @query.getPathInfo(@view).end.name

      s.get("model/#{type}").then (info) =>
          @$('.im-type-name').text info.name

      s.get("model/#{type}/#{attr}").then (info) =>
          @$('.im-attr-name').text pluralise(info.name)

      this
