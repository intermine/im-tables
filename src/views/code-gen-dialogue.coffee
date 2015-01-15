Modal = require './modal'

Messages = require '../messages'

require '../messages/code-gen'

module.exports = class ExportDialogue extends Modal

  initialize: ({@query}) ->
    super

  title: -> Messages.getText 'codegen.DialogueTitle', query: @query, lang: @model.get('lang')
