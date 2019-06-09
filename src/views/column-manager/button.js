QueryDialogueButton = require '../query-dialogue-button'
ColumnManger = require '../column-manager'

require '../../messages/columns'

# Simple component that just renders a button which when clicked
# will show the column manager dialogue.
module.exports = class ColumnMangerButton extends QueryDialogueButton

  # an identifying class.
  className: 'im-column-manager-button'

  longLabel: 'columns.ManageColumns'
  shortLabel: 'columns.ManageColumnsShort'
  icon: 'Columns'

  Dialogue: ColumnManger
