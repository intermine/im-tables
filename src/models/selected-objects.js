/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SelectedObjects;
const CoreModel = require('../core-model');
const Collection = require('../core/collection');

const types = require('../core/type-assertions');

// This class defines our expectations for the data that 
// the selected objects collection contains.
class SelectionModel extends CoreModel {

  defaults() {
    return {
      'class': null,
      'id': null
    };
  }

  validate(attrs, opts) {
    if ('class' in attrs) {
      if (attrs['class'] == null) { return '"class" must not be null'; }
    }

    if ('id' in attrs) {
      if (attrs.id == null) { return '"id" must not be null'; }
    }

    return false;
  }
}

// A collection that monitors its contents and calculates some
// aggregate values based on them - specificially the common
// type of its contents.
module.exports = (SelectedObjects = (function() {
  SelectedObjects = class SelectedObjects extends Collection {
    static initClass() {
  
      this.prototype.model = SelectionModel;
    }

    constructor(service) {
      super();
      types.assertMatch(types.Service, service, 'service');
      this.state = new CoreModel({node: null, commonType: null, typeName: null});
      this.listenTo(this.state, 'change:commonType', this.onChangeType);
      this.listenTo(this.state, 'change:node', this.onChangeNode);
      this.listenTo(this, 'add remove reset', this.setType);
      service.fetchModel().then(schema => { this.schema = schema; return this.setType(); });
    }

    onChangeNode() { return this.trigger('change:node change', this.state.get('node')); }

    onChangeType() {
      if (this.schema == null) { return; } // wait until we have the data model.
      const type = this.state.get('commonType');
      if (type == null) { return this.state.set({typeName: null}); }
      const path = this.schema.makePath(type);
      path.getDisplayName().then(name => {
        this.state.set({typeName: name});
        return this.trigger('change:typeName change');
      });
      return this.trigger('change:commonType change');
    }

    setType() {
      if (this.schema == null) { return; } // wait until we have the data model.

      var commonType = this.size() ?
        (commonType = this.schema.findCommonType(this.map(o => o.get('class'))))
      :
        null;

      if (commonType != null) {
        return this.state.set({commonType});
      } else {
        return this.state.set({
          commonType: null,
          typeName: null
        });
      }
    }
  };
  SelectedObjects.initClass();
  return SelectedObjects;
})());

