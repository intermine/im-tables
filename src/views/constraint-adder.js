// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ConstraintAdder;
const _ = require('underscore');

// Support
const Messages = require('../messages');
const Templates = require('../templates');
const View = require('../core-view');
const CoreModel = require('../core-model');
const PathSet = require('../models/path-set');
const OpenNodes = require('../models/open-nodes');

// Sub-views
const ConstraintAdderOptions = require('./constraint-adder-options');
const NewConstraint = require('./new-constraint');
const PathChooser = require('./path-chooser');

// Text strings
Messages.set({
  'constraints.BrowseForColumn': 'Browse for Column',
  'constraints.AddANewFilter': 'Add a new filter',
  'constraints.Choose': 'Choose',
  'constraints.Filter': 'Filter',
  'columns.CollapseAll': 'Collapse columns',
  'columns.AllowRevRef': 'Allow reverse references'
});

class ConstraintAdderModel extends CoreModel {
  
  defaults() {
    return {
      filter: null,              // No filter by default, but in the model for templates.
      showTree: true,            // Should we be showing the tree?
      allowRevRefs: false,       // Can we expand reverse references?
      canSelectReferences: true, // Can we select references?
      multiSelect: false        // Can we select multiple paths?
    };
  }
}

const OPTIONS_SEL = '.im-constraint-adder-options';

module.exports = (ConstraintAdder = (function() {
  ConstraintAdder = class ConstraintAdder extends View {
    constructor(...args) {
      {
        // Hack: trick Babel/TypeScript into allowing this before super.
        if (false) { super(); }
        let thisFn = (() => { return this; }).toString();
        let thisName = thisFn.match(/return (?:_assertThisInitialized\()*(\w+)\)*;/)[1];
        eval(`${thisName} = this;`);
      }
      this.showTree = this.showTree.bind(this);
      super(...args);
    }

    static initClass() {
  
      this.prototype.tagName = 'div';
  
      this.prototype.className = 'im-constraint-adder row-fluid';
    
      this.prototype.Model = ConstraintAdderModel;
  
      this.prototype.template = Templates.template('constraint_adder');
    }

    initialize({query, buttonDelegate}) {
      this.query = query;
      this.buttonDelegate = buttonDelegate;
      super.initialize(...arguments);
      this.model.set({
        root: this.query.getPathInfo(this.query.root)}); // Should never change.

      this.chosenPaths = new PathSet;
      this.view = new PathSet(Array.from(this.query.views).map((p) => this.query.makePath(p)));
      this.openNodes = new OpenNodes(this.query.getViewNodes()); // Open by default
      return this.listenTo(this.query, 'change:constraints', this.remove); // our job is done
    }

    modelEvents() {
      return {
        approved: this.handleApproval,
        'change:showTree': this.toggleTree,
        'change:constraint': this.onChangeConstraint
      };
    }

    getTreeRoot() { return this.model.get('root'); }

    handleApproval() {
      const [chosen] = Array.from(this.chosenPaths.toJSON());
      if (chosen != null) {
        const current = this.model.get('constraint');
        const newPath = chosen.toString();
        if ((current != null ? current.path : undefined) !== newPath) {
          const constraint = {path: newPath};
          this.model.set({constraint});
          // likely not necessary - remove? Tells containers which phase we are in.
          return this.query.trigger('editing-constraint', constraint);
        } else { // Path hasn't changed - go back to the constraint.
          return this.onChangeConstraint();
        }
      } else {
        console.debug('nothing chosen');
        return this.model.unset('constraint');
      }
    }

    renderConstraintEditor() {
      const constraint = this.model.get('constraint');
      const editor = new NewConstraint({buttonDelegate: this.buttonDelegate, query: this.query, constraint});
      this.renderChild('con', editor, this.$('.im-new-constraint'));
      return this.listenTo(editor, 'remove', function() { return this.model.set({showTree: true}); });
    }

    onChangeConstraint() { if (this.rendered) {
      if (this.model.get('constraint')) {
        this.model.set({showTree: false});
        return this.renderConstraintEditor();
      } else {
        return this.removeChild('con');
      }
    } }

    toggleTree() {
      if (this.model.get('showTree')) {
        return this.showTree();
      } else {
        return this.hideTree();
      }
    }

    hideTree() {
      this.trigger('resetting:tree');
      this.$('.im-path-finder').removeClass('open');
      return this.removeChild('tree');
    }

    showTree(e) {
      this.trigger('showing:tree');
      this.removeChild('con'); // Either show the tree or the constraint editor, not both.
      const pathFinder = new PathChooser({model: this.model, query: this.query, chosenPaths: this.chosenPaths, openNodes: this.openNodes, view: this.view, trail: []});
      this.$('.im-path-finder').addClass('open');
      return this.renderChild('tree', pathFinder, this.$('.im-path-finder'));
    }

    renderOptions() {
      const opts = {model: this.model, openNodes: this.openNodes, chosenPaths: this.chosenPaths, query: this.query};
      return this.renderChild('opts', (new ConstraintAdderOptions(opts)), this.$(OPTIONS_SEL));
    }

    postRender() {
      this.renderOptions();
      return this.toggleTree();
    }
  };
  ConstraintAdder.initClass();
  return ConstraintAdder; // respect the open status.
})());

