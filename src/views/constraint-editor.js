// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS204: Change includes calls to have a more natural evaluation order
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ConstraintEditor;
const _ = require('underscore');
const fs = require('fs');

const Messages = require('../messages');
const Icons = require('../icons');
const CoreView = require('../core-view');

const TypeValueControls = require('./type-value-controls');
const AttributeValueControls = require('./attribute-value-controls');
const MultiValueControls = require('./multi-value-controls');
const BooleanValueControls = require('./boolean-value-controls');
const LookupValueControls = require('./lookup-value-controls');
const LoopValueControls = require('./loop-value-controls');
const ListValueControls = require('./list-value-controls');
const ErrorMessage = require('./error-message');

const {Query, Model} = require('imjs');

// Operator sets
const {REFERENCE_OPS, LIST_OPS, MULTIVALUE_OPS, NULL_OPS, ATTRIBUTE_OPS, ATTRIBUTE_VALUE_OPS} = Query;
const {NUMERIC_TYPES, BOOLEAN_TYPES} = Model;

const BASIC_OPS = ATTRIBUTE_VALUE_OPS.concat(NULL_OPS);

const html = fs.readFileSync(__dirname + '/../templates/constraint-editor.html', 'utf8');

const TEMPLATE = _.template(html, {variable: 'data'});
const NO_OP = function() {}; // A function that doesn't do anything

const operatorsFor = function(opts) {
  let needle;
  const {path} = opts;
  if (!(path != null ? path.isReference : undefined)) { throw new Error('No path or wrong type'); }
  if (path.isRoot()) {
    REFERENCE_OPS.concat(Query.RANGE_OPS);
  }
  if (path.isReference()) {
    return REFERENCE_OPS.concat(Query.RANGE_OPS).concat(opts.new ? ['ISA'] : []);
  } else if ((needle = path.getType(), Array.from(BOOLEAN_TYPES).includes(needle))) {
    return ["=", "!="].concat(NULL_OPS);
  } else {
    return ATTRIBUTE_OPS;
  }
};

module.exports = (ConstraintEditor = (function() {
  ConstraintEditor = class ConstraintEditor extends CoreView {
    static initClass() {
  
      this.prototype.tagName = 'div';
  
      this.prototype.className = 'form';
  
      this.prototype.parameters = ['query', 'model'];
  
      // The buttonDelegate can be provided to trigger the button actions
      // instead of our own.
      // (TODO - find a better way to do that).
      this.prototype.optionalParameters = ['buttonDelegate'];
  
      this.prototype.template = TEMPLATE;
    }

    initialize() {
      super.initialize(...arguments);
      return this.path = this.model.get('path');
    }

    invariants() { return {modelHasPath: 'No path found on model'}; }

    modelHasPath() { return this.model.get('path'); }

    getType() { return this.model.get('path').getType(); }

    modelEvents() {
      return {
        'change:op change:displayName': this.reRender,
        'destroy': this.stopListening
      };
    }

    events() {
      return {
        'submit'(e) { e.preventDefault(); return e.stopPropagation(); },
        'click .btn-cancel': 'cancelEditing',
        'click .btn-primary': 'applyChanges',
        'change .im-ops': 'setOperator'
      };
    }

    delegateButtonEvents() {
      this.buttonDelegate.off('click.constraint-editor');
      this.buttonDelegate.on('click.constraint-editor', '.btn-cancel', () => this.cancelEditing());
      return this.buttonDelegate.on('click.constraint-editor', '.btn-primary', () => this.applyChanges());
    }

    setOperator() { return this.model.set({op: this.$('.im-ops').val()}); }

    cancelEditing() {
      return this.model.trigger('cancel');
    }

    applyChanges(e) {
      if (e != null) {
        e.preventDefault();
      }
      if (e != null) {
        e.stopPropagation();
      }
      return this.model.trigger('apply', this.getConstraint());
    }

    getConstraint() {
      let needle, needle1;
      const con = this.model.pick(['path', 'op', 'value', 'values', 'code', 'type']);

      if ((needle = con.op, Array.from(MULTIVALUE_OPS.concat(NULL_OPS)).includes(needle))) {
        delete con.value;
      }
    
      if ((needle1 = con.op, Array.from(ATTRIBUTE_VALUE_OPS.concat(NULL_OPS)).includes(needle1))) {
        delete con.values;
      }

      if (con.op === 'ISA') {
        delete con.op;
      }

      return con;
    }

    // The main dispatch mechanism, delegates to sub-views that know 
    // how to handle different constraint types.
    // dispatches to one of 8 constraint sub-types.
    getValueControls() {
      if ((this.path == null)) { // this constraint is in error.
        return null;
      }
      if (this.isNullConstraint()) {
        return null; // Null child components are ignored.
      }
      if (this.isTypeConstraint()) {
        return new TypeValueControls({model: this.model, query: this.query});
      }
      if (this.isMultiValueConstraint()) {
        return new MultiValueControls({model: this.model, query: this.query});
      }
      if (this.isListConstraint()) {
        return new ListValueControls({model: this.model, query: this.query});
      }
      if (this.isBooleanConstraint()) {
        return new BooleanValueControls({model: this.model, query: this.query});
      }
      if (this.isLoopConstraint()) {
        return new LoopValueControls({model: this.model, query: this.query});
      }
      if (this.isLookupConstraint()) {
        return new LookupValueControls({model: this.model, query: this.query});
      }
      if (this.isRangeConstraint()) {
        return new MultiValueControls({model: this.model, query: this.query});
      }
      if (this.path.isAttribute()) {
        return new AttributeValueControls({model: this.model, query: this.query});
      }
      this.model.set({error: new Error('cannot handle this constaint type')});
      return null;
    }

    isNullConstraint() { let needle;
    return (needle = this.model.get('op'), Array.from(NULL_OPS).includes(needle)); }

    isLoopConstraint() { let needle;
    return this.path.isClass() && ((needle = this.model.get('op'), ['=', '!='].includes(needle))); }

    // type constraints cannot be on the root, so isReference is perfect.
    isTypeConstraint() {
      return this.path.isReference() && (!this.model.get('op') || ('ISA' === this.model.get('op')));
    }

    isBooleanConstraint() { let needle, needle1;
    return ((needle = this.path.getType(), Array.from(BOOLEAN_TYPES).includes(needle))) && !((needle1 = this.model.get('op'), Array.from(NULL_OPS).includes(needle1))); }

    isMultiValueConstraint() { let needle;
    return this.path.isAttribute() && ((needle = this.model.get('op'), Array.from(MULTIVALUE_OPS).includes(needle))); }

    isListConstraint() { let needle;
    return this.path.isClass() && ((needle = this.model.get('op'), Array.from(LIST_OPS).includes(needle))); }

    isLookupConstraint() { let needle;
    return this.path.isClass() && ((needle = this.model.get('op'), Array.from(Query.TERNARY_OPS).includes(needle))); }

    isRangeConstraint() { let needle;
    return this.path.isReference() && ((needle = this.model.get('op'), Array.from(Query.RANGE_OPS).includes(needle))); }

    getOtherOperators() { return _.without(operatorsFor(this.model.pick('new', 'path')), this.model.get('op')); }

    buttons() {
      if (this.buttonDelegate != null) { return []; } // We will not need our own buttons in this case.
      // This is the ugliest part of the whole code really, but the alternative is an extra
      // class for little to gain.
      const buttons = [
          {
              key: "conbuilder.Update",
              classes: "im-update"
          },
          {
              key: "conbuilder.Cancel",
              classes: "btn-cancel"
          }
      ];
      if (this.model.get('new')) {
        buttons[0].key = 'conbuilder.Add';
        buttons[1].classes = "im-remove-constraint";
      } else {
        buttons.push({key: "conbuilder.Remove", classes: "btn btn-default im-remove-constraint"});
      }

      return buttons;
    }

    getData() {
      const buttons = this.buttons();
      const messages = Messages;
      const icons = Icons;
      const otherOperators = this.getOtherOperators();
      const con = this.model.toJSON();
      return {buttons, icons, messages, icons, otherOperators, con};
    }

    render() {
      super.render(...arguments);
      this.renderChild('valuecontrols', this.getValueControls(), this.$('.im-value-options'));
      this.renderChild('error', (new ErrorMessage({model: this.model})));
      if (this.buttonDelegate != null) {
        this.delegateButtonEvents();
      }
      return this;
    }

    remove() { // Animated removal
      if (this.buttonDelegate != null) {
        this.buttonDelegate.off('click.constraint-editor');
      }
      return this.$el.slideUp({always: () => ConstraintEditor.prototype.__proto__.remove.call(this, )});
    }
  };
  ConstraintEditor.initClass();
  return ConstraintEditor;
})());

