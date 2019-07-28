let InputWithButton;
const _ = require('underscore');
const CoreView = require('../core-view');
const Templates = require('../templates');

// Component that represents an input with an appended
// button. This component keeps the model value in sync
// with the displayed DOM value, and emits an 'act' event
// when the button is clicked.
module.exports = (InputWithButton = (function() {
  InputWithButton = class InputWithButton extends CoreView {
    static initClass() {
  
      this.prototype.className = 'input-group';
  
      this.prototype.template = Templates.template('input-with-button');
    }

    getData() { return _.extend(this.getBaseData(), {
      value: this.model.get(this.sets),
      placeholder: this.placeholder,
      button: this.button
    }
    ); }

    // If passed in with a model, then we set into that,
    // otherwise maintain our own model value.
    initialize({placeholder, button, sets}) {
      this.placeholder = placeholder;
      this.button = button;
      this.sets = sets;
      super.initialize(...arguments);
      return this.sets != null ? this.sets : (this.sets = 'value');
    }

    postRender() {
      return this.$el.addClass(this.className);
    }

    modelEvents() {
      const e = {};
      e[`change:${ this.sets }`] = this.setDomValue;
      return e;
    }

    events() {
      return {
        'keyup input': 'setModelValue',
        'click button': 'act'
      };
    }

    setModelValue(e) {
      return this.model.set(this.sets, e.target.value);
    }

    setDomValue() {
      const value = this.model.get(this.sets);
      const $input = this.$('input');
      const domValue = $input.val();

      if (domValue !== value) {
        return $input.val(value);
      }
    }

    act() { return this.trigger('act', this.model.get(this.sets)); }
  };
  InputWithButton.initClass();
  return InputWithButton;
})());

