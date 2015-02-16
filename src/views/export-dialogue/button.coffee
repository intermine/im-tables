_ = require 'underscore'

# Base class.
QueryDialogueButton = require '../query-dialogue-button'

# The model for this class.
ExportDialogue = require '../export-dialogue'

module.exports = class ExportDialogueButton extends QueryDialogueButton

  # an identifying class.
  className: 'im-export-dialogue-button'

  longLabel: 'export.ExportQuery'
  shortLabel: 'export.Export'
  icon: 'Download'

  optionalParameters: ['tableState']

  dialogueOptions: ->
    page = @tableState?.pick('start', 'size')
    {@query, model: {tablePage: page}}

  Dialogue: ExportDialogue
