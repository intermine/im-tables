/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let FilterDialogueButton;
const QueryDialogueButton = require('../query-dialogue-button');
const FilterDialogue = require('../filter-dialogue');

require('../../messages/constraints');

// Simple component that just renders a button which when clicked
// will show the filter manager dialogue.
module.exports = (FilterDialogueButton = (function() {
  FilterDialogueButton = class FilterDialogueButton extends QueryDialogueButton {
    static initClass() {
  
      // an identifying class.
      this.prototype.className = 'im-filter-dialogue-button';
  
      this.prototype.longLabel = 'constraints.ManageFilters';
      this.prototype.shortLabel = 'constraints.ManageFiltersShort';
      this.prototype.icon = 'Filter';
  
      this.prototype.Dialogue = FilterDialogue;
  }
};
  FilterDialogueButton.initClass();
  return FilterDialogueButton;
})());
