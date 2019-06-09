// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SingleColumnConstraints;
const Constraints = require('../constraints');
const SingleColumnConstraintAdder = require('./single-column-adder');
const ComposedColumnConstraintAdder = require('./composed-column-adder');

// Consumes a HeaderModel
module.exports = (SingleColumnConstraints = class SingleColumnConstraints extends Constraints {

  getConAdder() { if (this.shouldShowAdder()) {
    const {replaces, isComposed, outerJoined} = this.model.attributes;
    const path = this.model.pathInfo();
    if (isComposed && (replaces.length > 1)) {
      return new ComposedColumnConstraintAdder({query: this.query, paths: replaces});
    } else if (outerJoined) {
      return new ComposedColumnConstraintAdder({query: this.query, paths: [path].concat(replaces)});
    } else {
      return new SingleColumnConstraintAdder({query: this.query, path});
    }
  } }

  // Numeric paths can handle multiple constraints - others should just have one.
  shouldShowAdder() {
    const {numeric, isComposed, outerJoined} = this.model.attributes;
    return numeric || isComposed || outerJoined || (!this.getConstraints().length);
  }

  getConstraints() {
    const view = this.model.get('path');
    return ((() => {
      const result = [];
      for (let c of Array.from(this.query.constraints)) {         if (c.path.match(view)) {
          result.push(c);
        }
      }
      return result;
    })());
  }
});

