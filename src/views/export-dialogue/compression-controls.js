// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let CompressionControls;
const _ = require('underscore');
const ModalBody = require('./main');
const Templates = require('../../templates');

module.exports = (CompressionControls = (function() {
  CompressionControls = class CompressionControls extends ModalBody {
    static initClass() {
  
      this.prototype.RERENDER_EVENT = 'change';
  
      this.prototype.tagName = 'form';
  
      this.prototype.template = Templates.template('export_compression_controls');
  }

    setCompression(type) { return () => this.model.set({compression: type}); }

    events() {
      return {
          'click .im-compress': () => this.model.toggle('compress'),
          'click input[name=gzip]': this.setCompression('gzip'),
          'click input[name=zip]': this.setCompression('zip')
      };
  }
};
  CompressionControls.initClass();
  return CompressionControls;
})());

