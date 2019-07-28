// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SubtableInner;
const CoreView = require('../../core-view');
const SubtableHeader = require('./subtable-header');
const buildSkipped = require('../../utils/build-skipset');

// This class renders the rows and column headers of
// nested subtables. It is a thin wrapper around the 
// subcomponents that render the column headers and
// cells.
module.exports = (SubtableInner = (function() {
  SubtableInner = class SubtableInner extends CoreView {
    static initClass() {
  
      this.prototype.tagName = 'table';
  
      this.prototype.className = 'im-subtable table table-condensed table-striped';
  
      this.prototype.parameters = [ // things we want from the SubTable
        'query',
        'headers',
        'model',
        'rows',
        'cellify',
      ];
    }

    render() {
      this.removeAllChildren();
      if (this.rendered) { this.el.innerHTML = ''; }
      if (this.headers.length > 1) { this.renderHead(); }
      const tbody = document.createElement('tbody');
      for (let i = 0; i < this.rows.length; i++) {
        const row = this.rows[i];
        this.appendRow(row, i, tbody);
      }
      this.el.appendChild(tbody);
      this.trigger('rendered', (this.rendered = true));
      return this;
    }

    renderHead(table) {
      const head = new SubtableHeader({
        query: this.query,
        collection: this.headers,
        columnModel: this.model
      });
      return this.renderChild('thead', head, table);
    }

    buildSkipped(cells) { return this._skipped != null ? this._skipped : (this._skipped = buildSkipped(cells, this.headers)); }

    appendRow(row, i, tbody) {
      const tr = document.createElement('tr');
      tbody.appendChild(tr);
      const cells = (Array.from(row).map((c) => this.cellify(c)));

      const skipped = this.buildSkipped(cells);

      return (() => {
        const result = [];
        for (let j = 0; j < cells.length; j++) {
          const cell = cells[j];
          if (!skipped[cell.model.get('column')]) {
            result.push(this.renderChild(`cell-${ i }-${ j }`, cell, tr));
          }
        }
        return result;
      })();
    }
  };
  SubtableInner.initClass();
  return SubtableInner;
})());

