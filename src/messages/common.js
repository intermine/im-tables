// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
module.exports = {
  All: 'All',
  Reset: 'Reset',
  Export: "Download",
  Clear: 'Clear',
  Cancel: 'Cancel',
  Complete: 'Complete',
  Error: 'Error',
  Warning: 'Warning',
  Filter: 'Filter',
  Loading: 'Loading',
  Undo: 'Undo',
  and: 'and',
  or: 'or',
  comma: ',',
  Number: '<%= formatNumber(n) %>', // can be used in templates to access formatNumber
  'modal.DefaultTitle': 'Excuse me...',
  'modal.Dismiss': 'Close',
  'modal.OK': 'OK',
  'modal.ApplyChanges': 'Apply Changes',
  'core.NoOptions': 'There are no options to select from.',
  ErrorTitle({level}) { switch (level) {
    case 'Error': return 'Error';
    case 'Warning': return 'Warning';
    case 'Info': return 'nb';
    case 'Positive': return 'Success';
    default: return 'Error';
  } }
};
