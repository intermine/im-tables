let NewFilterDialogue;
const _ = require('underscore');

const Modal = require('./modal');
const ConstraintAdder = require('./constraint-adder');
const Templates = require('../templates');
const Messages = require('../messages');

// Very simple dialogue that just wraps a ConstraintAdder
module.exports = (NewFilterDialogue = (function() {
  NewFilterDialogue = class NewFilterDialogue extends Modal {
    static initClass() {
  
      this.prototype.modalSize = 'lg';
    }

    className() { return `im-constraint-dialogue ${super.className(...arguments)}`; }

    initialize({query}) {
      this.query = query;
      super.initialize(...arguments);
      this.listenTo(this.query, 'change:constraints', this.resolve); // Our job is done.
      return this.listenTo(this.query, 'editing-constraint', () => { // Can we do this on the model?
          return this.$('.im-add-constraint').removeClass('disabled');
      });
    }

    events() { return _.extend(super.events(...arguments), {
      'click .im-add-constraint': 'addConstraint',
      'childremoved': (e, child) => { if (child instanceof ConstraintAdder) { return this.hide(); } }
    }
    ); }

    title() { return Messages.getText('constraints.AddNewFilter'); }
    primaryAction() { return Messages.getText('constraints.AddFilter'); }

    postRender() {
      const footer = this.$('.modal-footer');
      const body = this.$('.modal-body');
      this.renderChild('adder', (new ConstraintAdder({buttonDelegate: footer, query: this.query})), body);
      return super.postRender(...arguments);
    }
  };
  NewFilterDialogue.initClass();
  return NewFilterDialogue;
})());
