Modal = require './modal'

Templates = require '../templates'
Messages = require '../messages'
Collection = require '../core/collection'

require '../messages/columns'

module.exports = class ColumnManager extends Modal

  title: -> Messages.getText 'columns.DialogueTitle'

  initialize: ->
    super

