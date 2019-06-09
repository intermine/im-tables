// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ClassSet;
const _ = require('underscore');

module.exports = (ClassSet = class ClassSet {

  constructor(definitions) {
    this.definitions = definitions;
  }

  activeClasses() { return ((() => {
    const result = [];
    for (let cssClass in this.definitions) {
      if (_.result(this.definitions, cssClass)) {
        result.push(cssClass);
      }
    }
    return result;
  })()); }

  toString() { return this.activeClasses().join(' '); }
});

