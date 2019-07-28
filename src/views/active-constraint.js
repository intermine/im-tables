let ActiveConstraint;
const _ = require('underscore');
const $ = require('jquery');

const {Promise} = require('es6-promise');
const {Query, Model} = require('imjs');

// Support
const CoreModel = require('../core-model');
const Messages = require('../messages');
const Templates = require('../templates');
const Icons = require('../icons');
const Options = require('../options');
const View = require('../core-view');

const ConstraintSummary = require('./constraint-summary');
const ConstraintEditor = require('./constraint-editor');

// It is very important that the ValuePlaceholder get set to the
// appropriate mine value.
// That should probably happen in some options system.
Messages.setWithPrefix('conbuilder', {
  Add: 'Add constraint',
  Update: 'Update',
  Cancel: 'Cancel',
  Remove: 'Remove',
  EditCon: 'Edit filter',
  NotEditable: 'This constraint is not editable',
  ValuePlaceholder: 'David*',
  ExtraPlaceholder: 'Wernham-Hogg',
  ExtraLabel: 'in',
  IsA: 'is a',
  NoValue: 'No value selected. Please enter a value.',
  NoOperator: 'No operator selected. Please choose an operator.',
  BadLoop: 'The selected path is not in the query.',
  NaN: 'The value provided is not a number.',
  Duplicate: 'This constraint is already on the query',
  TooManySuggestions: 'We cannot show you all the possible values',
  NoSuitableLists: 'No lists of this type are available',
  NoSuitableLoops: 'No suitable loop paths were found'
}
);

const aeql = function(xs, ys) {
  if (!xs && !ys) {
    return true;
  }
  if (!xs || !ys) {
    return false;
  }
  const [shorter, longer] = Array.from(_.sortBy([xs, ys], a => a.length));
  return _.all(longer, x => Array.from(shorter).includes(x));
};

const basicEql = function(a, b) {
  if (!a || !b) { return a === b; }
  const keys = _.union.apply(_, [a, b].map(_.keys));
  let same = true;
  for (var k of Array.from(keys)) {
    const [va, vb] = Array.from(([a, b].map((x) => x[k])));
    if (same) { same = (_.isArray(va) ? aeql(va, vb) : va === vb); }
  }
  return same;
};

class ConstraintModel extends CoreModel {

  defaults() {
    return {code: null};
  }

  isTypeConstraint() { return (this.get('op') == null); }
}

// Composite view with a summary, and controls for editing the constraint.
module.exports = (ActiveConstraint = (function() {
  let IS_BLANK = undefined;
  ActiveConstraint = class ActiveConstraint extends View {
    static initClass() {
  
      this.prototype.Model = ConstraintModel;
  
      this.prototype.tagName = "div";
  
      this.prototype.className = "im-constraint row-fluid";
  
      this.prototype.parameters = ['query', 'constraint'];
  
      this.prototype.optionalParameters = ['buttonDelegate'];
  
      IS_BLANK = /^\s*$/;
  
      this.prototype.template = (Templates.template('active-constraint', {variable: 'data'}));
    }

    initialize() {
      super.initialize(...arguments);
      // Model is the state of the constraint, with the path promoted to a full object.
      this.model.set(this.constraint);

      this.state.set({editing: false});
      this.listenTo(this.state, 'change:editing', this.toggleEditor);

      this.listenTo(this.model, 'change:type', this.setTypeName);
      this.listenTo(this.model, 'change:path', this.setDisplayName);

      // Declare rendering dependency on messages and icons.
      this.listenTo(Messages, 'change', this.reRender);

      this.listenTo(this.model, 'cancel', this.cancelEditing);
      this.listenTo(this.model, 'apply', this.applyChanges);
    
      try {
        this.model.set({path: this.query.makePath(this.constraint.path)});
      } catch (e) {
        this.model.set({error: e});
        this.state.set({editing: true});
      }

      return this.setTypeName();
    }

    setDisplayName() {
      return this.model.get('path').getDisplayName((error, displayName) => {
        this.model.set({error, displayName});
        if (error != null) {
          // Could have been caused by type constraints. Start listening.
          return this.listenToOnce(this.query, 'change:constraints', () => {
            this.model.set({path: this.query.getPathInfo(this.constraint.path)});
            return this.setDisplayName();
          });
        }
      });
    }

    cancelEditing() {
      this.state.set({editing: false});
      this.model.set(_.omit(this.constraint, 'path'));
      return this.model.set({error: null});
    }

    toggleEditing() {
      if (this.state.get('editing')) {
        return this.cancelEditing();
      } else {
        return this.state.set({editing: true});
      }
    }

    setTypeName() {
      const type = this.model.get('type');
      if ((type == null)) {
        return this.model.unset('typeName');
      } else {
        try {
          return this.query.model.makePath(type)
                .getDisplayName((error, typeName) => this.model.set({error, typeName}));
        } catch (e) { // bad path most likely.
          return this.model.set({error: e, typeName: type});
        }
      }
    }

    events() {
      return {
        'click .im-edit': 'toggleEditing',
        'click .im-remove-constraint': 'removeConstraint'
      };
    }

    getLoopProblem(con) {
      const problem = (() => { try {
        this.query.getPathInfo(con.value);
        return null;
      } catch (e) {
        return 'BadLoop';
      } })();
      return problem;
    }

    getValueProblem(con) {
      let needle;
      const {path, op, value} = con;
      // console.debug con
      if ((value == null) || (IS_BLANK.test(value))) {
        return 'NoValue';
      }

      if ((needle = path.getType(), Array.from(Model.NUMERIC_TYPES).includes(needle)) && (_.isNaN(1 * value))) {
        return 'NaN';
      }

      return null;
    }

    getProblem(con) {
      let needle;
      if (con.type != null) {
        return null; // Using a select list - cannot be wrong
      }

      if (!con.op || IS_BLANK.test(con.op)) { // No operator.
        return 'NoOperator';
      }

      if (con.path.isReference() && ['=', '!='].includes(con.op)) {
        return this.getLoopProblem(con);
      }

      if ((needle = con.op, Array.from(Query.ATTRIBUTE_VALUE_OPS.concat(Query.REFERENCE_OPS)).includes(needle))) {
        return this.getValueProblem(con);
      }

      if (this.isDuplicate(con)) {
        return 'Duplicate';
      }

      return null;
    }

    isDuplicate(con) { return _.any(this.query.constraints, _.partial(basicEql, con)); }

    setError(key) {
      const msg = Messages.get(`conbuilder.${ key }`);
      return this.model.set({error: msg});
    }

    applyChanges(con) {
      let silently;
      const problem = this.getProblem(con);
      if (problem != null) {
        return this.setError(problem);
      }

      this.state.set({editing: false});

      this.removeConstraint(null, (silently = true));

      if ((con.values != null) && !con.values.length) {
        // Empty multi-value constraint - treat as removal, and trigger the previously
        // suppressed change event.
        return this.query.trigger("change:constraints");
      } else {
        // console.debug 'Adding constraint'
        con.path = con.path.toString();
        this.query.addConstraint(con);
        this.constraint = con;
        return this.model.unset('new');
      }
    }

    // Used both by buttons for removal, and by the code that applies the changes.
    removeConstraint(e, silently) {
      if (silently == null) { silently = false; }
      if (e != null) {
        e.preventDefault();
      }
      if (e != null) {
        e.stopPropagation();
      }
      if (!this.model.get('new')) {
        this.query.removeConstraint(this.constraint, silently);
      }
      if (e != null) { // This is real removal - no point hanging about.
        return this.remove();
      }
    }

    getData() {
      const messages = Messages;
      const icons = Icons;
      const con = this.model.toJSON();
      return {icons, messages, con};
    }

    toggleEditor() {
      if (this.state.get('editing') && this.rendered) {
        const opts = {model: this.model, query: this.query, buttonDelegate: this.buttonDelegate};
        return this.renderChild('editor', (new ConstraintEditor(opts)), this.$('.im-constraint-editor'));
      } else {
        return this.removeChild('editor');
      }
    }

    renderSummary() {
      const opts = {model: this.model};
      return this.renderChild('summary', (new ConstraintSummary(opts)), this.$('.im-con-overview'));
    }

    postRender() {
      this.renderSummary();
      this.toggleEditor();
      return this.$('[title]').tooltip();
    }
  };
  ActiveConstraint.initClass();
  return ActiveConstraint;
})());
