// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ComposedColumnConstraintAdder;
const _ = require('underscore');
const CoreView = require('../../core-view');
const PathModel = require('../../models/path');
const Templates = require('../../templates');
const Messages = require('../../messages');
const ConstraintAdder = require('../constraint-adder');
const AdderButton = require('./column-adder-button');

require('../../messages/constraints');

const OPTS_SEL = '.im-constraint-adder-options';

class DropdownButtonGrp extends CoreView {
  static initClass() {
  
    this.prototype.className = 'btn-group';
  
    this.prototype.parameters = ['main', 'options'];
  
    this.prototype.ICONS = 'NONE';
  }

  initState() { return this.state.set({open: false}); }

  stateEvents() {
    return {'change:open': this.toggleOpen};
  }

  toggleOpen() { return this.$el.toggleClass('open', this.state.get('open')); }

  postRender() {
    this.toggleOpen();
    this.renderChild('main', this.main);
    this.renderChild('toggle', new Toggle({state: this.state}));
    const ul = document.createElement('ul');
    ul.className = 'dropdown-menu';
    for (let i = 0; i < this.options.length; i++) {
      const kid = this.options[i];
      this.renderChild(i, kid, ul);
    }
    return this.$el.append(ul);
  }
}
DropdownButtonGrp.initClass();

class Toggle extends CoreView {
  static initClass() {
  
    this.prototype.tagName = 'button';
  
    this.prototype.className = 'btn btn-primary dropdown-toggle';
  
    this.prototype.ICONS = 'NONE';
  
    this.prototype.template = _.template(`\
<span class="caret"></span>
<span class="sr-only"><%- Messages.getText('constraints.OtherPaths') %></span>\
`
    );
  }

  events() { return {click() { return this.state.toggle('open'); }}; }
}
Toggle.initClass();

class Option extends AdderButton {
  static initClass() {
  
    this.prototype.tagName = 'li';
  
    this.prototype.className = '';
  }

  template() { return `<a>${ super.template(...arguments) }</a>`; }
}
Option.initClass();

module.exports = (ComposedColumnConstraintAdder = (function() {
  ComposedColumnConstraintAdder = class ComposedColumnConstraintAdder extends ConstraintAdder {
    static initClass() {
  
      this.prototype.parameters = ['query', 'paths'];
    }

    onChosen(path) { return this.model.set({constraint: {path}}); }

    renderOptions() {} // nothing to do here.

    showTree() {
      const [p, ...ps] = Array.from(this.paths);
      const mainButton = new AdderButton({hideType: true, model: (new PathModel(p))});
      const opts = Array.from(ps).map((p_) =>
        new Option({hideType: true, model: (new PathModel(p_))}));
      const grp = new DropdownButtonGrp({main: mainButton, options: opts});

      for (let b of [mainButton, ...Array.from(opts)]) {
        this.listenTo(b, 'chosen', this.onChosen);
      }

      return this.renderChild('tree', grp, this.$(OPTS_SEL));
    }
  };
  ComposedColumnConstraintAdder.initClass();
  return ComposedColumnConstraintAdder;
})());

