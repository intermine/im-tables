Backbone = require 'backbone'

# Forms a pair with models/cell
#
module.exports = class NestedTableModel extends Backbone.Model

  initialize: ->
    @setNames()
    @on 'change:column', @setNames, @ # Should never happen.

  destroy: ->
    @off()
    super

  setNames: ->
    column = @get 'column'
    column.getDisplayName().then (name) =>
      @set columnName: name
    column.getType().getDisplayName().then (name) =>
      @set columnTypeName: name
