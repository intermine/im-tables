// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let TableBody;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Templates = require('../../templates');

const buildSkipped = require('../../utils/build-skipset');

require('../../messages/table');

module.exports = (TableBody = (function() {
  TableBody = class TableBody extends CoreView {
    static initClass() {
  
      this.prototype.tagName = 'tbody';
  
      this.prototype.parameters = ['makeCell', 'collection', 'history'];
    }

    collectionEvents() {
      return {
        reset: this.reRender,
        add: this.onRowAdded,
        remove: this.onRowRemoved
      };
    }
  
    template() {}

    initialize() {
      super.initialize(...arguments);
      return this._skipSets = {}; // cache - one per table.
    }

    renderChildren() {
      if (this.collection.isEmpty()) {
        return this.handleEmptyTable();
      } else {
        const frag = document.createDocumentFragment('tbody');
        this.collection.forEach(row => this.addRow(row, frag));
        return this.el.appendChild(frag);
      }
    }

    onRowAdded(row) {
      this.removeChild('apology');
      return this.addRow(row);
    }

    onRowRemoved(row) {
      this.removeChild(row.id);
      if (this.collection.isEmpty()) {
        return this.handleEmptyTable();
      }
    }

    addRow(row, tbody) {
      if (tbody == null) { tbody = this.el; }
      const skipped = this.skipped(row);
      const view = new RowView({model: row, makeCell: this.makeCell, skipped});
      return this.renderChild(row.id, view, tbody);
    }

    handleEmptyTable() {
      return this.renderChild('apology', new EmptyApology({history: this.history}));
    }

    skipped(row) { // one of the uglier parts of the codebase.
      let name;
      return this._skipSets[name = row.get('query')] != null ? this._skipSets[name] : (this._skipSets[name] = (() => { // builds and throws away cells
        const temps = row.get('cells').map(this.makeCell);
        const ret = buildSkipped(temps);
        temps.forEach(t => t.remove());
        return ret;
      })());
    }
  };
  TableBody.initClass();
  return TableBody;
})());

class RowView extends CoreView {
  static initClass() {
  
    this.prototype.tagName = 'tr';
  
    this.prototype.parameters = ['makeCell', 'skipped'];
  }

  postRender() {
    const cells = this.model.get('cells').map(this.makeCell);
    return (() => {
      const result = [];
      for (let i = 0; i < cells.length; i++) {
        const cell = cells[i];
        if (!this.skipped[cell.model.get('column')]) {
          result.push(this.renderChild(i, cell));
        }
      }
      return result;
    })();
  }
}
RowView.initClass();

class EmptyApology extends CoreView {
  static initClass() { // pun fully intended ;)
  
    this.prototype.tagName = 'tr';
  
    this.prototype.className = 'im-empty-apology';
  
    this.prototype.template = Templates.template('no-results');
  
    this.prototype.parameters = ['history'];
  }

  events() { return {'click .btn-undo'() { return this.history.popState(); }}; }

  getData() { return _.extend(super.getData(...arguments), {
    selectList: this.history.getCurrentQuery().views,
    canUndo: (this.history.length > 1)
  }
  ); }
}
EmptyApology.initClass();
