_ = require 'underscore'
CoreView = require '../../core-view'
Templates = require '../../templates'
Collection = require '../../core/collection'
PathModel = require '../../models/path'
DropDownColumnSummary = require './column-summary'

class SubColumns extends Collection

  model: PathModel

class SubColumn extends CoreView

  parameters: ['showPathSummary']

  className: 'im-subpath im-outer-joined-path'

  tagName: 'li'

  template: _.template """
    <a href="#">#{ Templates.column_manager_path_name }</a>
  """

  modelEvents: -> change: @reRender

  events: -> click: @onClick
  
  onClick: (e) ->
    e.stopPropagation()
    e.preventDefault()
    @showPathSummary @model.get 'path'

module.exports = class OuterJoinDropDown extends CoreView

  parameters: ['query']

  className: 'im-summary-selector'

  tagName: 'ul'

  initialize: ->
    super
    @subColumns = new SubColumns
    for c in @model.get 'replaces'
      @subColumns.add @query.makePath c
    @path = new PathModel @query.makePath @model.get 'path'

  getSubpaths: -> @subColumns

  postRender: ->
    paths = @getSubpaths()
    return @showPathSummary paths.first() if paths.length is 1
    showPathSummary = (v) => @showPathSummary v
    @getSubpaths().each (model, i) =>
      @renderChild i, (new SubColumn {model, showPathSummary})

  showPathSummary: (v) ->
    @undelegateEvents() # stop listening to the element we are ceding control of
    @removeAllChildren() # remove all the LIs we added.
    summ = new DropDownColumnSummary {@query, path: v}
    @children.summ = summ # reference it so it can be reaped.
    summ.setElement @el # pass control of element to new view.
    summ.render()
