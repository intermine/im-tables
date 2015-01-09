CoreView = require '../../core-view'

module.exports = class FrequencyVisualisation extends CoreView

  chartHeight: 100

  initialize: ({@query, @view}) ->
    super

  _drawD3Chart: -> throw new Error 'Not Implemented'

  postRender: -> @addChart()

  addChart: ->
    @chartElem = @make "div"
    @$el.append @chartElem
    setTimeout (=> @_drawD3Chart()), 0 if d3?
    this

