_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

require '../../messages/table'

module.exports = class TableSummary extends CoreView

  className: 'im-table-summary hidden-phone'

  RERENDER_EVENT: 'change:start change:size change:count'

  getData: ->
    {start, size, count} = data = super
    _.extend data, page:
      count: count
      first: start + 1
      last: if (size is 0) then 0 else Math.min(start + size, count)

  template:  Templates.template 'count_summary'
