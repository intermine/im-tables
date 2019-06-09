QueryDialogueButton = require '../query-dialogue-button'
JoinManager = require '../join-manager'

require '../../messages/joins'

# Simple component that just renders a button which when clicked
# will show the filter manager dialogue.
module.exports = class JoinManagerButton extends QueryDialogueButton

  # an identifying class.
  className: 'im-join-manager-button'

  longLabel: 'joins.Manage'
  shortLabel: 'joins.ManageShort'
  icon: 'Joins'

  Dialogue: JoinManager
