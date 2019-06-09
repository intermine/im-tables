// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let JSONOptions;
const _ = require('underscore');
const View = require('../../core-view');
const LabelView = require('../label-view');
const Messages = require('../../messages');
const Templates = require('../../templates');

module.exports = (JSONOptions = (function() {
  JSONOptions = class JSONOptions extends View {
    static initClass() {
  
      this.prototype.RERENDER_EVENT = 'change';
  
      this.prototype.tagName = 'form';
  
      this.prototype.template = Templates.template('export_json_options');
  }

    setJSONFormat(fmt) { return () => this.model.set({jsonFormat: fmt}); }

    events() {
      return {
          'click input[name=rows]': this.setJSONFormat('rows'),
          'click input[name=objects]': this.setJSONFormat('objects')
      };
  }
};
  JSONOptions.initClass();
  return JSONOptions;
})());

