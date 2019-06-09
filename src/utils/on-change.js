// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Produce an event name for the change of multiple properties
let onChange;
module.exports = (onChange = props =>
  props.map(p => `change:${ p }`)
       .join(' ')
);

