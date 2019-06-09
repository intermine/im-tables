/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SelectWithLabel;
const _ = require('underscore');
const Templates = require('../templates');

const InputWithLabel = require('./input-with-label');

// One word of caution - you should never inject the state into
// this component (except for observation). If two components share
// the same state object, they will probably collide on the validation
// state. The only valid reason to do such a thing would be if two
// such or similar components write to the same value.
module.exports = (SelectWithLabel = (function() {
  SelectWithLabel = class SelectWithLabel extends InputWithLabel {
    static initClass() {
  
      this.prototype.template = Templates.template('select-with-label');
  
      this.prototype.noOptionsMessage = 'core.NoOptions';
    }

    parameters() { return ['model', 'collection', 'attr', 'label', 'optionLabel']; }

    optionalParameters() { return ['noOptionsMessage'].concat(super.optionalParameters(...arguments)); }

    events() {
      return {'change select': 'setModelValue'};
    }

    collectionEvents() {
      return {'add remove reset change': this.reRender};
    }

    getData() {
      const currentlySelected = this.model.get(this.attr);
      return _.extend(this.getBaseData(), {
        label: this.label,
        model: this.model.toJSON(),
        selected(list) { return list.name === currentlySelected; },
        options: this.collection.toJSON(),
        optionLabel: this.optionLabel,
        helpMessage: this.helpMessage,
        noOptionsMessage: this.noOptionsMessage,
        hasProblem: this.state.get('problem')
      }
      );
    }
  };
  SelectWithLabel.initClass();
  return SelectWithLabel;
})());

