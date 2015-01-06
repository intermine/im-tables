_ = require 'underscore'

View = require '../core-view'
Templates = require '../templates'
{numToString} = require '../templates/helpers'

template = Templates.template 'count_summary'

# This needs a test/index

module.exports = class TableSummary extends View

  className: 'im-table-summary hidden-phone'

  RERENDER_EVENT: 'change:start change:size change:count'

  template: ({start, size, count}) ->
    return unless size and count

    template
      first: start + 1
      last: if (size is 0) then 0 else Math.min(start + size, count)
      count: numToString(count)
      roots: "rows"
