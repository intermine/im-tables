View = require '../core-view'

# FIXME - make this import work, was CountSummary
template = require '../templates/table-summary'
# FIXME - check this import
{numToString} = require '../views/helpers'

EVT = 'change:start change:size change:count'

module.exports = class TableSummary extends View

  className: 'im-table-summary'

  initialize: ->
    super
    @listenTo @model, EVT, @render

  template: ({start, size, count}) ->
    return unless size and count

    template
      first: start + 1
      last: if (size is 0) then 0 else Math.min(start + size, count)
      count: numToString(count, ",", 3)
      roots: "rows"
