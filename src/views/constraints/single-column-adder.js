/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SingleColumnConstraintAdder;
const _ = require('underscore');
const CoreView = require('../../core-view');
const PathModel = require('../../models/path');
const Templates = require('../../templates');
const Messages = require('../../messages');
const ConstraintAdder = require('../constraint-adder');
const AdderButton = require('./column-adder-button');

require('../../messages/constraints');

const OPTS_SEL = '.im-constraint-adder-options';

module.exports = (SingleColumnConstraintAdder = (function() {
  SingleColumnConstraintAdder = class SingleColumnConstraintAdder extends ConstraintAdder {
    static initClass() {
  
      this.prototype.parameters = ['query', 'path'];
    }

    initialize() {
      super.initialize(...arguments);
      const constraint = {path: this.path};
      return this.model.set({constraint});
    }

    events() {
      return {'click .im-add-constraint': this.act};
    }
  
    act() {
      this.hideTree();
      return this.renderConstraintEditor();
    }

    renderOptions() {} // nothing to do here.

    showTree() {
      const model = new PathModel(this.query.makePath(this.path));
      const button = new AdderButton({model});
      return this.renderChild('tree', (new AdderButton({model})), this.$(OPTS_SEL));
    }
  };
  SingleColumnConstraintAdder.initClass();
  return SingleColumnConstraintAdder;
})());


