_ = require 'underscore'

# Base class.
QueryDialogueButton = require '../query-dialogue-button'

# The model for this class.
ExportDialogue = require '../export-dialogue'

Counter = require '../../utils/count-executor'

module.exports = class ExportDialogueButton extends QueryDialogueButton

  # an identifying class.
  className: 'im-export-dialogue-button'

  longLabel: 'export.ExportQuery'
  shortLabel: 'export.Export'
  icon: 'Download'

  optionalParameters: ['tableState']

  initialize: ->
    super
    Counter.count @query # Disable export if no results or in error.
           .then (count) => @state.set disabled: count is 0
           .then null, (err) => @state.set disabled: true, error: err

  dialogueOptions: ->
    page = @tableState?.pick('start', 'size')
    {@query, model: {tablePage: page}}

  Dialogue: ExportDialogue
