/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let BooleanValueControls;
const _ = require('underscore');
const fs = require('fs');

const Messages = require('../messages');
const View = require('../core-view');
const Options = require('../options');

const mustacheSettings = require('../templates/mustache-settings');

const html = fs.readFileSync(__dirname + '/../templates/boolean-value-controls.html', 'utf8');

module.exports = (BooleanValueControls = (function() {
  BooleanValueControls = class BooleanValueControls extends View {
    static initClass() {
  
      this.prototype.className = 'im-value-options btn-group';
  
      this.prototype.template = _.template(html, mustacheSettings);
    }

    modelEvents() { return {change: this.reRender}; }

    getData() { return _.extend({value: null}, super.getData(...arguments)); }

    events() {
      return {
        'click .im-true': 'setValueTrue',
        'click .im-false': 'setValueFalse'
      };
    }

    setValueTrue() { return this.model.set({value: true}); }

    setValueFalse() { return this.model.set({value: false}); }
  };
  BooleanValueControls.initClass();
  return BooleanValueControls;
})());

