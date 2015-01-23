CoreView = require '../../core-view'
Templates = require '../../templates'
Options = require '../../options'

PathSet = require '../../models/path-set'
OpenNodes = require '../../models/open-nodes'

PathChooser = require '../path-chooser'

class Buttons extends CoreView

  parameters: ['collection', 'selectList']

  template: Templates.template 'column-manager-path-chooser-buttons'

  collectionEvents: ->
    'add remove reset': 'reRender'

  events: ->
    'click .im-add-column': 'addColumn'
    'click .im-rearrange-columns': 'cancel'

  cancel: ->
    @trigger 'done'
  
  addColumn: ->
    selectList = @selectList
    paths = @collection.paths()
    @cancel()
    selectList.add paths

module.exports = class ColumnChooser extends CoreView

  parameters: ['query', 'collection']

  template: Templates.template 'column-manager-path-chooser'

  initialize: ->
    super
    @chosenPaths = new PathSet
    @view = new PathSet(@query.makePath p for p in @collection.pluck 'path')
    @openNodes = new OpenNodes @query.getViewNodes() # Open by default

  initState: ->
    @query.makePath(@query.root).getDisplayName().then (name) => @state.set rootName: name

  stateEvents: ->
    'change:rootName': 'reRender'

  postRender: ->
    @renderButtons()
    @openPathChooser()

  renderButtons: ->
    btns = new Buttons {@state, collection: @chosenPaths, selectList: @collection}
    @listenTo btns, 'done', => @trigger 'done'
    @renderChildAt '.btn-group', btns

  openPathChooser: ->
    model =
      dontSelectView: true
      multiSelect: (Options.get 'ColumnManager.SelectColumn.Multi')
    pathChooser = new PathChooser {model, @query, @chosenPaths, @openNodes, @view, trail: []}
    @renderChild 'pathChooser', pathChooser
    @setPathChooserHeight()

  setPathChooserHeight: -> # Don't let it get too big.
    @$('.im-path-chooser').css 'max-height': (@$el.closest('.modal').height() - 350)

  remove: ->
    @chosenPaths.close()
    @view.close()
    @openNodes.close()
    super

