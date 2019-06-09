// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let MultiValueControls;
const _ = require('underscore');
let {Collection} = require('backbone');

const Messages = require('../messages');
const Templates = require('../templates');
const Icons = require('../icons');
const View = require('../core-view');
const Model = require('../core-model');
Collection = require('../core/collection');
const Options = require('../options');
const {IS_BLANK} = require('../patterns');
const {ignore} = require('../utils/events');

Messages.setWithPrefix('multivalue', {
  AddValue: 'Add value',
  AddValueShort: '+',
  SaveValue: 'Save changes'
}
);

const mustacheSettings = require('../templates/mustache-settings');

class ValueModel extends Model {
  static initClass() {
  
    this.prototype.idAttribute = 'value';
  }

  defaults() {
    return {
      editing: false,
      scratch: null,
      selected: true
    };
  }
}
ValueModel.initClass();

class Values extends Collection {
  static initClass() {
  
    this.prototype.model = ValueModel;
  }
}
Values.initClass();

class ValueControl extends View {
  static initClass() {
  
    this.prototype.Model = ValueModel;
  
    this.prototype.tagName = 'tr';
  
    this.prototype.template = Templates.template('value-control-row', mustacheSettings);
  }

  initialize() {
    this.model.set({editing: false, scratch: this.model.get('value')});
    return this.listenTo(this.model, 'change:editing change:value change:selected', this.reRender);
  }

  events() {
    return {
      'click .input-group'(e) { return (e != null ? e.stopPropagation() : undefined); },
      'click .im-edit': 'editValue',
      'keyup input': 'updateScratch',
      'change input': 'updateScratch',
      'click .im-save': 'saveValue',
      'click .im-cancel': 'cancelEditing',
      'click': 'toggleSelected' // Very broad - want to capture row clicks too.
    };
  }

  updateScratch(e) {
    ignore(e);
    return this.model.set({scratch: e.target.value});
  }

  // scratch value becomes real value. Editing stops.
  saveValue(e) {
    ignore(e);
    return this.model.set({editing: false, value: this.model.get('scratch')});
  }

  // reset scratch value with real value. Editing stops.
  cancelEditing(e) {
    ignore(e);
    return this.model.set({editing: false, scratch: this.model.get('value')});
  }

  editValue(e) {
    ignore(e);
    return this.model.toggle('editing');
  }

  toggleSelected(e) {
    ignore(e);
    return this.model.toggle('selected');
  }

  getData() { return _.extend({icons: Icons, messages: Messages}, this.model.toJSON()); }
}
ValueControl.initClass();

module.exports = (MultiValueControls = (function() {
  MultiValueControls = class MultiValueControls extends View {
    static initClass() {
  
      this.prototype.className = 'im-value-options im-multi-value-table';
  
      this.prototype.template = Templates.template('add-value-control');
    }

    initialize() {
      super.initialize(...arguments);
      this.values = new Values;
      for (let v of Array.from((this.model.get('values') || []))) {
        this.values.add({value: v});
      }
      this.listenTo(this.values, 'change:selected change:value add', this.updateModel);
      this.listenTo(this.values, 'add', this.renderValue);
      return this.listenTo(this.values, 'remove', this.removeValue);
    }

    stateEvents() {
      return {'change:value': this.onChangeNewValue};
    }

    // Help translate between multi-value and =
    // changing the op elsewhere triggers this controller to change the
    // value(s).
    modelEvents() {
      return {
        'change:op': this.onChangeOp,
        'change:values': this.onChangeValues
      };
    }

    onChangeValues() {
      // We only need to reset if transitioning from non-multi constraint.
      if (this.model.previous('values') != null) { return; }
      const current = this.model.get('values');
      return this.values.set((Array.from(current != null ? current : [])).map((value) => ({value})));
    }

    onChangeOp() {
      const newOp = this.model.get('op');
      if (['=', '!='].includes(newOp) && (!this.model.has('value'))) {
        return this.model.set({values: null, value: this.values.first().get('value')});
      }
    }

    events() {
      return {
        'keyup .im-new-multi-value': this.updateNewValue,
        'click .im-add': this.addValue
      };
    }

    // Two-way binding between state.value and .im-new-multi-value
    onChangeNewValue() {
      return this.$('.im-new-multi-value').val(this.state.get('value'));
    }

    updateNewValue() {
      return this.state.set({value: this.$('.im-new-multi-value').val()});
    }

    addValue(e) {
      ignore(e);
      const value = this.state.get('value');
      if (((value == null)) || IS_BLANK.test(value)) {
        this.model.set({error: new Error('please enter a value')});
        return this.listenToOnce(this.state, 'change:value', () => this.model.unset('error'));
      } else {
        this.values.add({value});
        return this.state.unset('value');
      }
    }

    updateModel() {
      return this.model.set({values: ((Array.from(this.values.where({selected: true})).map((m) => m.get('value'))))});
    }

    getData() { return {messages: Messages}; }

    postRender() {
      this.$table = this.$('table');
      return this.renderRows();
    }

    renderRows() { return this.values.each(m => this.renderValue(m)); }

    removeValue() { return this.removeChild(m.id); }

    renderValue(m) {
      return this.renderChild(m.id, (new ValueControl({model: m})), this.$table);
    }

    remove() {
      this.values.close();
      return super.remove(...arguments);
    }
  };
  MultiValueControls.initClass();
  return MultiValueControls;
})());

