{DashBoard} = require './dash-board'

{Trail} = require './trail'

class exports.Toolless extends DashBoard

  className: 'im-query-display im-toolless'

  TABLE_CLASSES: 'im-query-results'

  renderTools: (q) ->

  renderQueryManagement: (q) ->
    trail = new Trail(@states)
    @$el.prepend trail.render().el

