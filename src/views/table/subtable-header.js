/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SubtableHeaders;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Templates = require('../../templates');

require('../../messages/subtables');

class SubtableHeader extends CoreView {
  static initClass() {
  
    this.prototype.tagName = 'th';
  
    this.prototype.parameters = ['columnModel', 'model', 'query'];
  
    this.prototype.template = Templates.template('table-subtables-header');
  }

  getData() { return _.extend(super.getData(...arguments), this.columnModel.pick('columnName')); }

  modelEvents() { return {'change:displayName': this.reRender}; }

  events() { return {'click a': this.removeView}; }

  removeView() {
    let left;
    return this.query.removeFromSelect((left = this.model.get('replaces')) != null ? left : this.model.get('path'));
  }

  postRender() {
    return this.$('[title]').tooltip();
  }

  initialize() {
    super.initialize(...arguments);
    return this.listenTo(this.columnModel, 'change:columnName', this.reRender);
  }

  remove() {
    delete this.columnModel;
    return super.remove(...arguments);
  }
}
SubtableHeader.initClass();

module.exports = (SubtableHeaders = (function() {
  SubtableHeaders = class SubtableHeaders extends CoreView {
    static initClass() {
  
      this.prototype.tagName = 'thead';
  
      this.prototype.parameters = [
        'collection', // the column headers
        'columnModel', // The model of the column we are on.
        'query', // Needed because we will need to remove views.
      ];
    }

    template() { return '<tr></tr>'; }

    collectionEvents() {
      return {'add remove': this.reRender};
    }

    renderChildren() {
      const tr = this.el.querySelector('tr');
      return this.collection.forEach((model, i) => {
        return this.renderChild(i, (new SubtableHeader({model, query: this.query, columnModel: this.columnModel})), tr);
      });
    }

    remove() {
      delete this.columnModel;
      return super.remove(...arguments);
    }
  };
  SubtableHeaders.initClass();
  return SubtableHeaders;
})());

