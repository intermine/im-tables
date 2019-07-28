let InputWithLabel;
const _ = require('underscore');
const CoreView = require('../core-view');
const Templates = require('../templates');

// One word of caution - you should never inject the state into
// this component (except for observation). If two components share
// the same state object, they will probably collide on the validation
// state. The only valid reason to do such a thing would be if two
// such or similar components write to the same value.
module.exports = (InputWithLabel = (function() {
  InputWithLabel = class InputWithLabel extends CoreView {
    static initClass() {
  
      this.prototype.className = 'form-group';
  
      this.prototype.template = Templates.template('input-with-label');
  
      // Nothing by default - provide one to give help if there is a problem. Also,
      // problems may define their own help (see ::getProblem).
      this.prototype.helpMessage = null;
    }

    parameters() { return ['attr', 'placeholder', 'label']; }

    optionalParameters() { return ['getProblem', 'helpMessage']; }

    // A function that takes the model value and returns a Problem if there is one
    // A Problem is any truthy value. For simple cases `true` will do just fine,
    // but the following fields are recognised:
    //   - level: 'warning' or 'error' - default = 'error'
    //   - message: A Messages key to replace the text in the help block.
    getProblem(value) { return null; }

    initialize() {
      super.initialize(...arguments);
      return this.setValidity();
    }

    setValidity() { return this.state.set({problem: this.getProblem(this.model.get(this.attr))}); }

    getData() { return _.extend(this.getBaseData(), {
      value: this.model.get(this.attr),
      label: this.label,
      placeholder: this.placeholder,
      helpMessage: this.helpMessage,
      hasProblem: this.state.get('problem')
    }
    ); }

    postRender() {
      this.$el.addClass(this.className); // in case we were renderedAt
      return this.onChangeValidity();
    }

    events() {
      return {'keyup input': 'setModelValue'};
    }

    stateEvents() { return {'change:problem': this.onChangeValidity}; }

    modelEvents() {
      const e = {};
      e[`change:${ this.attr }`] = this.onChangeValue;
      return e;
    }

    onChangeValue() {
      this.setValidity();
      return this.setDOMValue();
    }

    onChangeValidity() {
      const problem = this.state.get('problem');
      const help = this.$('.help-block');
      if (problem) {
        this.$el.toggleClass('has-warning', (problem.level === 'warning'));
        this.$el.toggleClass('has-error', (problem.level !== 'warning'));
        if (problem.message != null) { help.text(Messages.getText(problem.message)); }
        return help.slideDown();
      } else {
        this.$el.removeClass('has-warning has-error');
        return help.slideUp();
      }
    }

    setModelValue(e) {
      return this.model.set(this.attr, this.$(e.target).val()); // Use val so sub-classes can use it.
    }

    setDOMValue() {
      const $input = this.$('input');
      const domValue = $input.val();
      const modelValue = this.model.get(this.attr);
      // We check that this is necessary to avoid futzing about with the cursor.
      if (modelValue !== domValue) {
        return $input.val(modelValue);
      }
    }
  };
  InputWithLabel.initClass();
  return InputWithLabel;
})());

