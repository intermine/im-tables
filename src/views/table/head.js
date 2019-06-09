// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let TableHead;
const _ = require('underscore');
const CoreView = require('../../core-view');
const ColumnHeader = require('./header');

module.exports = (TableHead = (function() {
  TableHead = class TableHead extends CoreView {
    static initClass() {
  
      this.prototype.tagName = 'thead';
  
      this.prototype.parameters = [
        'history',
        'expandedSubtables',
        'blacklistedFormatters',
        'columnHeaders',
      ];
    }

    template() {}

    initialize() {
      super.initialize(...arguments);
      this.listenTo(this.columnHeaders, 'add reset sort', this.reRender);
      this.listenTo(this.columnHeaders, 'remove', function(ch) { return this.removeChild(ch.id); });
      return this;
    }

    renderChildren() {
      const docfrag = document.createDocumentFragment();
      const tr = document.createElement('tr');
      docfrag.appendChild(tr);
      const query = this.history.getCurrentQuery();

      const headerOpts = {query, expandedSubtables: this.expandedSubtables, blacklistedFormatters: this.blacklistedFormatters};

      this.columnHeaders.each(this.renderHeader(tr, headerOpts));
            
      return this.$el.html(docfrag);
    }

    // Render a single header to the row of headers
    renderHeader(tr, opts) { return (model, i) => {
      const header = new ColumnHeader(_.extend({model}, opts));
      return this.renderChild(model.id, header, tr);
    }; }
  };
  TableHead.initClass();
  return TableHead;
})());

