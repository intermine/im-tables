/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let FastaOptions;
const _ = require('underscore');
const View = require('../../core-view');
const LabelView = require('../label-view');
const Messages = require('../../messages');
const Templates = require('../../templates');

module.exports = (FastaOptions = (function() {
  FastaOptions = class FastaOptions extends View {
    static initClass() {
  
      this.prototype.RERENDER_EVENT = 'change';
  
      this.prototype.tagName = 'form';
  
      this.prototype.template = Templates.template('export_fasta_options');
  }

    setFastaExtension(ext) { return this.model.set({fastaExtension: ext}); }

    events() {
      return {'change .im-fasta-ext': e => this.setFastaExtension(e.target.value)};
  }
};
  FastaOptions.initClass();
  return FastaOptions;
})());

