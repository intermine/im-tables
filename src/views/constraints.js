// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let Constraints;
const _ = require('underscore');

const CoreView = require('../core-view');
const Templates = require('../templates');

const ConstraintAdder = require('./constraint-adder');
const ActiveConstraint = require('./active-constraint');

require('../messages/constraints');

module.exports = (Constraints = (function() {
  Constraints = class Constraints extends CoreView {
    static initClass() {
  
      this.prototype.className = "im-constraints";
  
      this.prototype.template = Templates.templateFromParts(['constraints-heading', 'active-constraints']);
    }

    initialize({query}) {
      this.query = query;
      super.initialize(...arguments);
      return this.listenTo(this.query, "change:constraints", this.reRender);
    }

    getData() { return _.extend(super.getData(...arguments), {constraints: this.getConstraints()}); }

    events() { return {click(e) { return (e != null ? e.stopPropagation() : undefined); }}; }

    postRender() {
      const container = this.$('.im-active-constraints');

      const iterable = this.getConstraints();
      for (let i = 0; i < iterable.length; i++) {
        const constraint = iterable[i];
        this.renderChild(`con_${ i }`, (new ActiveConstraint({query: this.query, constraint})), container);
      }

      return this.renderChild('conAdder', this.getConAdder());
    }

    getConstraints() { return this.query.constraints.slice(); }

    getConAdder() { return new ConstraintAdder({query: this.query}); }
  };
  Constraints.initClass();
  return Constraints;
})());

