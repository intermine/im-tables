{DashBoard} = require './dash-board'

{ToolBar} = require './tool-bar'

class exports.CompactView extends DashBoard

  className: "im-query-display compact"

  TABLE_CLASSES: "im-query-results"

  renderTools: (q) ->
    @toolbar = new ToolBar @states
    @tools.append @toolbar.render().el

