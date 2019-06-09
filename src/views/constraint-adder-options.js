// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS201: Simplify complex destructure assignments
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ConstraintAdderOptions;
const _ = require('underscore');
const {Promise} = require('es6-promise');

const View = require('../core-view');
const Options = require('../options');
const Templates = require('../templates');
const HasTypeaheads = require('../mixins/has-typeaheads');
const {IS_BLANK} = require('../patterns');

const pathSuggester = require('../utils/path-suggester');
const getPathSuggestions = require('../utils/path-suggestions');

const shortenLongName = function(name) {
  const parts = name.split(' > ');
  if (parts.length > 3) {
    const adjustedLength = Math.max(parts.length, 3),
      rest = parts.slice(0, adjustedLength - 3),
      x = parts[adjustedLength - 3],
      y = parts[adjustedLength - 2],
      z = parts[adjustedLength - 1];
    return `...${ x } > ${ y } > ${ z }`;
  } else {
    return name;
  }
};

// The control elements of a constraint adder.
module.exports = (ConstraintAdderOptions = (function() {
  ConstraintAdderOptions = class ConstraintAdderOptions extends View {
    static initClass() {
  
      this.include(HasTypeaheads);
  
      this.prototype.className = 'row';
  
      this.prototype.template = Templates.template('constraint_adder_options');
    }

    initialize({query, openNodes, chosenPaths}) {
      this.query = query;
      this.openNodes = openNodes;
      this.chosenPaths = chosenPaths;
      super.initialize(...arguments);
      this.state.set({chosen: []}); // default value.
      this.listenTo(this.openNodes, 'add remove reset', this.reRender);
      this.listenTo(this.chosenPaths, 'add remove reset', this.reRender);
      this.listenTo(this.chosenPaths, 'add remove reset', this.setChosen);
      this.setChosen();
      return this.generatePathSuggestions();
    }

    modelEvents() {
      return {
        destroy: this.stopListeningTo,
        'change:showTree change:allowRevRefs': this.reRender
      };
    }

    stateEvents() {
      return {'change:chosen change:suggestions': this.reRender};
    }

    pathAcceptable(path) {
      if ((path.end != null ? path.end.name : undefined) === 'id') {
        return false;
      }
      if (!this.model.get('canSelectReferences')) {
        return path.isAttribute();
      }
      return true;
    }

    generatePathSuggestions() {
      const depth = Options.get('SuggestionDepth');
      return getPathSuggestions(this.query, depth).then(suggestions => {
        return this.state.set({suggestions: suggestions.filter(s => this.pathAcceptable(s.path))});
      });
    }

    getData() {
      const anyNodesOpen = this.openNodes.size();
      const anyNodeChosen = this.chosenPaths.size();
      return _.extend({anyNodesOpen, anyNodeChosen}, this.state.toJSON(), super.getData(...arguments));
    }

    render() {
      super.render(...arguments);
      if (this.state.has('suggestions')) {
        this.installTypeahead();
      }
      return this;
    }

    installTypeahead() {
      this.removeTypeAheads(); // no more than one at a time.
      const input = this.$('.im-tree-filter');
      const suggestions = this.state.get('suggestions');
      const suggest = pathSuggester(suggestions);

      const opts = {
        minLength: 3,
        highlight: true
      };
      const dataset = {
        name: 'path_suggestions',
        source: suggest,
        displayKey: 'name'
      };

      return this.activateTypeahead(input, opts, dataset, suggestions[0].name, (e, suggestion) => {
        const { path } = suggestion;
        this.openNodes.add(path);
        if (this.model.get('multiSelect')) {
          return this.chosenPaths.add(path);
        } else {
          return this.chosenPaths.reset([path]);
        }
    });
    }

    events() {
      return {
        'click .im-collapser': 'collapseBranches',
        'change .im-allow-rev-ref': 'toggleReverseRefs',
        'change .im-tree-filter': 'setFilter',
        'click .im-choose': 'toggleShowTree',
        'click .im-approve': 'triggerApproval',
        'click .im-clear-filter': 'clearFilter'
      };
    }

    triggerApproval() { return this.model.trigger('approved'); }

    remove() {
      this.removeTypeAheads(); // here rather in removeAllChildren, since it was causing errors.
      return super.remove(...arguments);
    }

    clearFilter() {
      this.model.set({filter: null});
      return this.reRender();
    }

    setFilter(e) {
      const { value } = e.target;
      return this.model.set({filter: (IS_BLANK.test(value) ? null : value)});
    }

    collapseBranches() { return this.openNodes.reset(); }

    toggleShowTree() { return this.model.toggle('showTree'); }

    toggleReverseRefs() { return this.model.toggle('allowRevRefs'); }

    setConstraint() { return this.model.trigger('approved'); }

    setChosen() {
      const paths = this.chosenPaths.toJSON();
      const naming = Promise.all(Array.from(paths).map((p) => p.getDisplayName()));
      return naming.then(names => Array.from(names).map((n) => shortenLongName(n)))
            .then((names => this.state.set({chosen: names})), (e => console.error(e)));
    }
  };
  ConstraintAdderOptions.initClass();
  return ConstraintAdderOptions;
})());

