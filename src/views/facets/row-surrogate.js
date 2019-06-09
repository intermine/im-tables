/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let RowSurrogate;
const _ = require('underscore');
const CoreView = require('../../core-view');
const Templates = require('../../templates');

module.exports = (RowSurrogate = (function() {
  RowSurrogate = class RowSurrogate extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-facet-surrogate';
  
      this.prototype.template = Templates.template('row_surrogate');
    }

    initialize({above}) { this.above = above; return super.initialize(...arguments); }

    getData() { return _.extend(super.getData(...arguments), {above: this.above}); }

    postRender() { return this.$el.addClass(this.above ? 'above' : 'below'); }

    remove() { return this.$el.fadeOut('fast', () => RowSurrogate.prototype.__proto__.remove.call(this, )); }
  };
  RowSurrogate.initClass();
  return RowSurrogate;
})());

