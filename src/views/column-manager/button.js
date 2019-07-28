// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ColumnMangerButton;
const QueryDialogueButton = require('../query-dialogue-button');
const ColumnManger = require('../column-manager');

require('../../messages/columns');

// Simple component that just renders a button which when clicked
// will show the column manager dialogue.
module.exports = (ColumnMangerButton = (function() {
  ColumnMangerButton = class ColumnMangerButton extends QueryDialogueButton {
    static initClass() {
  
      // an identifying class.
      this.prototype.className = 'im-column-manager-button';
  
      this.prototype.longLabel = 'columns.ManageColumns';
      this.prototype.shortLabel = 'columns.ManageColumnsShort';
      this.prototype.icon = 'Columns';
  
      this.prototype.Dialogue = ColumnManger;
  }
};
  ColumnMangerButton.initClass();
  return ColumnMangerButton;
})());
