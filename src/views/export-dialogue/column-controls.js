/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS104: Avoid inline assignments
 * DS204: Change includes calls to have a more natural evaluation order
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ColumnControls;
const _ = require('underscore');
const View = require('../../core-view');
const PathSet = require('../../models/path-set');
const LabelView = require('../label-view');
const Messages = require('../../messages');
const Templates = require('../../templates');
const HasTypeaheads = require('../../mixins/has-typeaheads');
const pathSuggester = require('../../utils/path-suggester');

class HeadingLabel extends LabelView {
  static initClass() {
  
    this.prototype.template = _.partial(Messages.getText, 'export.category.Columns');
  }
}
HeadingLabel.initClass();

class AddColumnControl extends View {
  static initClass() {
  
    this.include(HasTypeaheads);
  
    this.prototype.className = 'col-sm-8';
  
    this.prototype.template = Templates.template('export_add_column_control');
  }

  initialize({columns, query}) {
    this.columns = columns;
    this.query = query;
    super.initialize(...arguments);
    return this.initSuggestions();
  }

  addSuggestion(path) {
    if (!this.columns.contains(path)) {
      this.suggestions.add(path);
      const m = this.suggestions.get(path);
      return path.getDisplayName((error, name) => m.set({error, name}));
    }
  }

  initSuggestions() {
    this.suggestions = new PathSet;
    const nodes = this.query.getQueryNodes();
    return Array.from(nodes).map((node) =>
      (() => {
        const result = [];
        for (let cn of Array.from(node.getChildNodes())) {
          if (cn.isAttribute()) {
            if (!this.columns.contains(cn)) { result.push(this.addSuggestion(cn)); } else {
              result.push(undefined);
            }
          }
        }
        return result;
      })());
  }

  postRender() {
    const input = this.$('input');
    const opts = {
      minLength: 1,
      highlight: true
    };
    const dataset = {
      name: 'view_suggestions',
      source: pathSuggester(this.suggestions),
      displayKey: 'name'
    };
    this.activateTypeahead(input, opts, dataset, 'Additional paths', (e, suggestion) => {
      const path = suggestion.item;
      return this.columns.add(path, {active: true});
    });
    return this.$('.im-help').tooltip();
  }
}
AddColumnControl.initClass();

class ResetButton extends View {
  static initClass() {
  
    this.prototype.className = 'col-sm-4';
  
    this.prototype.RERENDER_EVENT = 'change:isAll';
  
    this.prototype.template = Templates.template('reset_button');
  }

  initialize({query, columns}) {
    this.query = query;
    this.columns = columns;
    super.initialize(...arguments);
    this.setIsAll();
    return this.listenTo(this.columns, 'change:active', this.setIsAll);
  }

  setIsAll() {
    const view = this.query.views;
    const cols = (Array.from(this.columns.where({active: true})).map((c) => c.get('item').toString()));
    return this.model.set({isAll: _.isEqual(view, cols)});
  }

  events() {
    return {'click button': 'reset'};
  }

  reset() {
    const view = this.query.views;
    return this.columns.each(function(c) {
      const path = c.get('item').toString();
      return c.set({active: _.any(view, v => v === path)});
    });
  }
}
ResetButton.initClass();

class ColumnView extends View {
  static initClass() {
  
    this.prototype.RERENDER_EVENT = 'change';
  
    this.prototype.className = 'list-group-item';
  
    this.prototype.tagName = 'li';
  
    this.prototype.template = Templates.template('export_column_control');
  }

  initialize() {
    super.initialize(...arguments);
    if (!this.model.has('active')) { this.model.set({active: true}); }
    if (!this.model.has('name')) {
      this.model.set({name: null}); // make sure it is present.
      let path = this.model.get('item');
      if (__guard__(this.model.get('item').end, x => x.name) === 'id') { path = path.getParent(); }
      return path.getDisplayName((error, name) => {
        return this.model.set({error, name});
    });
    }
  }

  events() {
    return {'click .im-active-state': () => this.model.toggle('active')};
  }
}
ColumnView.initClass();

module.exports = (ColumnControls = (function() {
  ColumnControls = class ColumnControls extends View {
    static initClass() {
  
      this.prototype.className = 'container-fluid';
  
      this.prototype.tagName = 'form';
  
      this.prototype.template = Templates.template('export_column_controls');
    }

    initialize({query}) {
      let ns;
      this.query = query;
      super.initialize(...arguments);
      this.columns = new PathSet;
      // (re)-establish the state of the column selection, including
      // columns from the view that are not currently selected.
      const format = this.model.get('format');
      const activeCols = this.model.get('columns');
      if (!(format.needs != null ? format.needs.length : undefined)) {
        for (var v of Array.from(this.query.views)) {
          const p = this.query.makePath(v);
          this.columns.add(p, {active: (_.any(activeCols, ac => ac === v))});
        }
      }
      for (let c of Array.from(activeCols)) {
        this.columns.add(this.query.makePath(c), {active: true});
      }
      if (ns = this.model.get('nodecolumns')) {
        for (let n of Array.from(ns)) {
          this.columns.add(this.query.makePath(n), {active: false});
        }
      }

      this.listenTo(this.columns, 'add remove reset change:active', this.setColumns);
      return this.listenTo(this.columns, 'add remove reset', this.reRender);
    }

    // Make sure the selected columns (model.columns) reflects the selected
    // state of the column in this component.
    setColumns(m) {
      let max;
      let c;
      let columns = ((() => {
        const result = [];
        for (c of Array.from(this.columns.where({active: true}))) {           result.push(c.get('item').toString());
        }
        return result;
      })());
      if (max = this.model.get('format').maxColumns) {
        if ((m != null) && (columns.length > max)) {
          const newlySelected = m.get('item').toString();
          const others = ((() => {
            const result1 = [];
            for (c of Array.from(columns)) {               if (c !== newlySelected) {
                result1.push(c);
              }
            }
            return result1;
          })());
          columns = [newlySelected].concat(_.first(others, max - 1));
          _.defer(() => (() => {
            const result2 = [];
            for (c of Array.from(this.columns.where({active: true}))) {
              var needle;
              result2.push(c.set({active: ((needle = c.get('item').toString(), Array.from(columns).includes(needle)))}));
            }
            return result2;
          })()
          );
        }
      }
      return this.model.set({columns});
    }

    postRender() {
      const ul = this.$('ul');
      const ctrls = this.$('.controls');
      this.columns.each((c, i) => {
        return this.renderChild(i, (new ColumnView({model: c})), ul);
      });
      this.renderChild('reset', (new ResetButton({query: this.query, columns: this.columns})), ctrls);
      return this.renderChild('add', (new AddColumnControl({query: this.query, columns: this.columns})), ctrls);
    }
  };
  ColumnControls.initClass();
  return ColumnControls;
})());


function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}