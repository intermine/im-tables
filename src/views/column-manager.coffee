Modal = require './modal'

Templates = require '../templates'
Messages = require '../messages'
Collection = require '../core/collection'
PathModel = require '../models/path'
ColumnManagerTabs = require './column-manager/tabs'

require '../messages/columns'

class OrderByModel extends PathModel

  constructor: ({path, direction}) ->
    super path
    @set {direction}

class SelectList extends Collection

  model: (p) -> new PathModel p

class OrderByList extends Collection

  model: (args) -> new OrderByModel args

module.exports = class ColumnManager extends Modal

  parameters: ['query']

  title: -> Messages.getText 'columns.DialogueTitle'

  initialize: ->
    super
    # Populate the select list and sort-order with the current state of the
    # query.
    @selectList = new SelectList
    for v in @query.views
      @selectList.add @query.makePath v
    @sortOrder = new OrderByList
    for {path, direction} in @query.sortOrder
      @sortOrder.add {direction, path: @query.makePath(path)}

  postRender: ->
    super
    @renderChild 'tabs', (new ColumnManagerTabs {@state}), @$ '.modal-body'


