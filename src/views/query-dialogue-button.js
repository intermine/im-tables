let QueryDialogueButton;
const _ = require('underscore');
const CoreView = require('../core-view');
const Templates = require('../templates');

// Simple component that just renders a button which when clicked
// will show the a query dialogue, specified by the Dialogue property,
// which should be a constructor or a factory accepting a single argument
// of the form: {query :: Query}
module.exports = (QueryDialogueButton = (function() {
  QueryDialogueButton = class QueryDialogueButton extends CoreView {
    static initClass() {
  
      // The template for this component.
      this.prototype.template = Templates.template('modal-dialogue-opener');
  
      // This component receives a query from its parent.
      this.prototype.parameters = ['query'];
    }

    // Implementing classes must specifiy this property.
    Dialogue() { throw new Error('Not implemented'); }

    // Implementing classes should specify a message name, as a property or method.
    longLabel() { throw new Error('Not implemented'); }
    shortLabel() { throw new Error('Not implemented'); }
    icon() { throw new Error('Not implemented'); }

    labels() {
      return {
        ICON: (_.result(this, 'icon')),
        LONG: (_.result(this, 'longLabel')),
        SHORT: (_.result(this, 'shortLabel'))
      };
    }

    initState() { return this.state.set({disabled: false}); }

    events() { return {click: this.onClick}; }

    createDialogue() { return new this.Dialogue(this.dialogueOptions()); }

    dialogueOptions() { return {query: this.query}; }

    stateEvents() {
      return {
        'change:disabled'() {
          return this.$('.btn.im-open-dialogue').toggleClass('disabled', this.state.get('disabled'));
        }
      };
    }

    // Show the dialogue, unless disabled or already being shown.
    onClick(e) { if (!this.state.get('disabled')) {
      const dialogue = this.createDialogue();
      this.renderChild('dialogue', dialogue);
      this.state.set({disabled: true});
      const done = () => {
        this.removeChild('dialogue');
        document.body.classList.remove('modal-open'); // hangs around.
        return _.defer(() => this.state.set({disabled: false}));
      };
      return dialogue.show().then(done, done);
    } }
  };
  QueryDialogueButton.initClass();
  return QueryDialogueButton;
})());

