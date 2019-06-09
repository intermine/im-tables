// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
const Messages = require('../messages');

Messages.setWithPrefix('logic', {
  Heading: 'Manage Constraint Logic',
  Manage() { return Messages.getText('logic.Heading'); }, // synonymous by default - can be made distinct.
  ManageShort: 'Constraint Logic',
  LogicLabel() { return Messages.getText('logic.ManageShort'); },
  ApplyLogic: 'Change logic'
}
);
