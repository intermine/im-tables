CoreView = require '../core-view'
{UnionOf, Listenable, Structure} = Types = require '../core/type-assertions'

ColumnMangerButton   = require './column-manager/button'
FilterDialogueButton = require './filter-dialogue/button'
JoinManagerButton    = require './join-manager/button'

HistoryType = UnionOf Listenable, new Structure 'History',
  getCurrentQuery: Types.Function

module.exports = class QueryManagement extends CoreView

  className: 'im-query-management'

  parameters: ['history']

  parameterTypes:
    history: HistoryType

  initialize: ->
    super
    @listenTo @history, 'changed:current', @reRender

  renderChildren: ->
    query = @history.getCurrentQuery()
    @renderChild 'cols', (new ColumnMangerButton {query})
    @renderChild 'cons', (new FilterDialogueButton {query})
    @renderChild 'joins', (new JoinManagerButton {query})


