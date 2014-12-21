fs = require 'fs'
_ = require 'underscore'
View = require '../core-view'

html = fs.readFileSync __dirname + '/../templates/count-summary.mtpl', 'utf8'
template = _.template html
{numToString} = require '../templates/helpers'

EVT = 'change:start change:size change:count'

# This needs a test/index

module.exports = class TableSummary extends View

  className: 'im-table-summary hidden-phone'

  initialize: ->
    super
    @listenTo @model, EVT, @reRender

  template: ({start, size, count}) ->
    return unless size and count

    template
      first: start + 1
      last: if (size is 0) then 0 else Math.min(start + size, count)
      count: numToString(count)
      roots: "rows"
