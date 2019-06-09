/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let FlatFileOptions;
const _ = require('underscore');
const View = require('../../core-view');
const Templates = require('../../templates');

module.exports = (FlatFileOptions = (function() {
  FlatFileOptions = class FlatFileOptions extends View {
    static initClass() {
  
      this.prototype.RERENDER_EVENT = 'change';
  
      this.prototype.tagName = 'form';
  
      this.prototype.template = Templates.template('export_flat_file_options');
  }

    setHeaderType(type) { return () => this.model.set({headerType: type}); }

    events() {
      return {
          'click .im-headers': () => this.model.toggle('headers'),
          'click input[name=hdrs-friendly]': this.setHeaderType('friendly'),
          'click input[name=hdrs-path]': this.setHeaderType('path')
      };
  }
};
  FlatFileOptions.initClass();
  return FlatFileOptions;
})());

