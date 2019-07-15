let NestedTableModel;
const _ = require('underscore');

const CoreModel = require('../core-model');

// Forms a pair with models/cell

module.exports = (NestedTableModel = class NestedTableModel extends CoreModel {

  defaults() {
    return {
      columnName: null,
      columnTypeName: null,
      columnName: null,
      typeName: null,
      column: null, // :: PathInfo
      node: null, // :: PathInfo
      fieldName: null,
      contentName: null,
      view: [], // [String]
      rows: [] // [CellModel]
    };
  }

  initialize() {
    this.onChangeColumn();
    return this.listenTo(this, 'change:column', this.onChangeColumn); // Should never happen.
  }

  onChangeColumn() { // Set the display names.
    let column = this.get('column');
    let node = this.get('node');
    const views = this.get('view');
    if (views.length === 1) { // Use the single column as our column.
      column = column.model.makePath(views[0], column.subclasses);
      node = column.isAttribute() ? column.getParent() : column;
    }

    node.getType().getDisplayName().then(name => this.set({columnTypeName: name}));
    return column.getDisplayName().then(name => {
      this.set({columnName: name});
      if (column.isAttribute()) { this.set({fieldName: _.last(name.split(' > '))}); }
      return this.set({contentName: _.compact([this.get('columnTypeName'), this.get('fieldName')]).join(' ')});
    });
  }

  getPath() { return this.get('column'); }

  toJSON() { return _.extend(super.toJSON(...arguments), {
    column: this.get('column').toString(),
    node: this.get('node').toString(),
    rows: this.get('rows').map(r => r.map(c => c.toJSON()))
  }
  ); }
});
