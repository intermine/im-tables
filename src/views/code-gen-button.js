let CodeGenButton;
const _ = require('underscore');

const CoreView = require('../core-view');

// Text strings
const Messages = require('../messages');
// Configuration
const Options = require('../options');
// Templating
const Templates = require('../templates');
// The model for this class.
const CodeGenModel = require('../models/code-gen');
const Dialogue = require('./code-gen-dialogue');

// This class uses the code-gen message bundle.
require('../messages/code-gen');

class MainButton extends CoreView {
  static initClass() {
  
    this.prototype.template = Templates.template('code-gen-button-main');
  }

  modelEvents() {
    return {'change:lang': this.reRender};
  }
}
MainButton.initClass();

module.exports = (CodeGenButton = (function() {
  CodeGenButton = class CodeGenButton extends CoreView {
    static initClass() {
  
      this.prototype.parameters = ['query', 'tableState'];
  
      // Connect this view with its model.
      this.prototype.Model = CodeGenModel;
  
      // The template which renders this view.
      this.prototype.template = Templates.template('code-gen-button');
    }

    // The data that the template renders.
    getData() { return _.extend(super.getData(...arguments), {options: Options.get('CodeGen')}); }

    renderChildren() {
      return this.renderChildAt('.im-show-code-gen-dialogue', new MainButton({model: this.model}));
    }

    events() {
      return {
        'click .dropdown-menu.im-code-gen-langs li': 'chooseLang',
        'click .im-show-code-gen-dialogue': 'showDialogue'
      };
    }

    chooseLang(e) {
      const lang = this.$(e.target).closest('li').data('lang');
      this.model.set({lang});
      return this.showDialogue();
    }

    showDialogue() {
      const page = this.tableState.pick('start', 'size');
      const dialogue = new Dialogue({query: this.query, model: this.model, page});
      this.renderChild('dialogue', dialogue);
      // Returns a promise, but in this case we don't care about it.
      return dialogue.show();
    }
  };
  CodeGenButton.initClass();
  return CodeGenButton;
})());
