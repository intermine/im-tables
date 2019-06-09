QueryDialogueButton = require '../query-dialogue-button'
FilterDialogue = require '../filter-dialogue'

require '../../messages/constraints'

# Simple component that just renders a button which when clicked
# will show the filter manager dialogue.
module.exports = class FilterDialogueButton extends QueryDialogueButton

  # an identifying class.
  className: 'im-filter-dialogue-button'

  longLabel: 'constraints.ManageFilters'
  shortLabel: 'constraints.ManageFiltersShort'
  icon: 'Filter'

  Dialogue: FilterDialogue
