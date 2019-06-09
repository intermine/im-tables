/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let JoinManagerButton;
const QueryDialogueButton = require('../query-dialogue-button');
const JoinManager = require('../join-manager');

require('../../messages/joins');

// Simple component that just renders a button which when clicked
// will show the filter manager dialogue.
module.exports = (JoinManagerButton = (function() {
  JoinManagerButton = class JoinManagerButton extends QueryDialogueButton {
    static initClass() {
  
      // an identifying class.
      this.prototype.className = 'im-join-manager-button';
  
      this.prototype.longLabel = 'joins.Manage';
      this.prototype.shortLabel = 'joins.ManageShort';
      this.prototype.icon = 'Joins';
  
      this.prototype.Dialogue = JoinManager;
  }
};
  JoinManagerButton.initClass();
  return JoinManagerButton;
})());
