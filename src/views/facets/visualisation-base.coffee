CoreView = require '../../core-view'

module.exports = class VisualisationBase extends CoreView

  chartHeight: 100

  # This method needs implementing by sub-classes - standard ABC stuff here.
  _drawD3Chart: -> throw new Error 'Not Implemented'

  postRender: -> @addChart()

  addChart: -> setTimeout => @_drawD3Chart()

