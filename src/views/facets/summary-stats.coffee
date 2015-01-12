CoreView = require '../../core-view'
Templates = require '../../templates'

module.exports = class SummaryStats extends CoreView

  RERENDER_EVT: 'change'

  className: 'im-summary-stats'

  template: Templates.template 'summary_stats'

