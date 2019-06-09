/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let UndoStep;
const _ = require('underscore');
const CoreView = require('../../core-view');
const Collection = require('../../core/collection');
const Templates = require('../../templates');
const M = require('../../messages');
const PathModel = require('../../models/path');
const ConstraintModel = require('../../models/constraint');
const OrderElementModel = require('../../models/order-element');
const QueryProperty = require('./query-property-section');

require('../../messages/undo');
require('../../messages/constraints');

// A class annotation that adds an 'added :: bool'
// attribute to a Model
const withAdded = function(Base) { let WithAddedAndRemoved;
return (WithAddedAndRemoved = class WithAddedAndRemoved extends Base {
  defaults() { return _.extend(super.defaults(...arguments), {added: false, removed: false}); }
}); };

class ObjConstructorPM extends PathModel {

  constructor({path}) { super(path); }
}

class ViewList extends Collection {
  static initClass() {
  
    this.prototype.model = withAdded(ObjConstructorPM);
  }
}
ViewList.initClass();

class ConstraintList extends Collection {
  static initClass() {
  
    this.prototype.model = withAdded(ConstraintModel);
  }
}
ConstraintList.initClass();

class SortOrder extends Collection {
  static initClass() {
  
    this.prototype.model = withAdded(OrderElementModel);
  }
}
SortOrder.initClass();

// Return a factory that will lift .path and .type to Path from strings.
const liftPathAndType = query => function(obj) {
  obj = (_.isString(obj)) ? {path: obj} : obj;
  // Path must be interpreted with the relevant type constraint information.
  const attrs = {path: query.makePath(obj.path)};
  // Type must be interpreted directly from the model - it is just a type name.
  if (obj.type) { attrs.type = query.model.makePath(obj.type); } 
  return _.extend(attrs, (_.omit(obj, 'path', 'type')));
} ;

module.exports = (UndoStep = (function() {
  UndoStep = class UndoStep extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-step';
      this.prototype.tagName = 'li';
      this.prototype.template = Templates.template('undo-history-step');
    }

    getData() { return _.extend(super.getData(...arguments), {diff: this.getCountDiff()}); }

    getCountDiff() {
      if (this.state.has('prevCount')) {
        return this.model.get('count') - this.state.get('prevCount');
      } else {
        return null;
      }
    }

    initialize() {
      super.initialize(...arguments);
      const q = this.model.get('query');
      this.initPrevCount();
      const lifter = liftPathAndType(q);
      this.listenTo(this.model.collection, 'add remove', this.setCurrent);
      this.views = new ViewList(q.views.map(lifter));
      this.constraints = new ConstraintList(q.constraints.map(lifter));
      this.sortOrder = new SortOrder(q.sortOrder.map(lifter));
      const title = this.model.get('title');
      if (['Added', 'Removed', 'Changed'].includes(title.verb)) {
        switch (title.label) {
          case 'column': return this.diffView();
          case 'sort order element': return this.diffSortOrder();
          case 'filter': return this.diffConstraints();
          case 'Initial': return null; // Ignore.
          default: return console.error('Cannot diff', title.label);
        }
      }
    }

    initPrevCount() { let prev;
    if (prev = this.getPrevModel()) {
      this.state.set({prevCount: prev.get('count')});
      return this.listenTo(prev, 'change:count', () => this.state.set({prevCount: prev.get('count')}));
    } }

    getPrevModel() {
      const index = this.model.collection.indexOf(this.model);
      if (index === 0) { return null; }
      return this.model.collection.at(index - 1);
    }

    diff(prop, coll, test) {
      let e, i;
      const prev = this.getPrevModel();
      const currQuery = this.model.get('query');
      const prevQuery = prev.get('query');
      // Find added, mark as such.
      for (i = 0; i < currQuery[prop].length; i++) {
        e = currQuery[prop][i];
        if (test(e, prevQuery)) {
          coll.at(i).set({added: true});
        }
      }
      // Find removed elements, add them and mark them as such
      // TODO: handle errors from bad paths - which should not happen.
      const lifter = liftPathAndType(prevQuery);
      return (() => {
        const result = [];
        for (i = 0; i < prevQuery[prop].length; i++) {
          e = prevQuery[prop][i];
          if (test(e, currQuery)) {
            result.push(coll.add(lifter(e), {at: i}).set({removed: true}));
          }
        }
        return result;
      })();
    }

    diffView() {
      return this.diff('views', this.views, (v, {views}) => !Array.from(views).includes(v));
    }

    diffSortOrder() {
      return this.diff('sortOrder', this.sortOrder, (oe, q) => !_.findWhere(q.sortOrder, oe));
    }

    diffConstraints() {
      return this.diff('constraints', this.constraints, (c, q) => !_.findWhere(q.constraints, c));
    }

    initState() {
      return this.setCurrent();
    }

    setCurrent() {
      if (!(this.model != null ? this.model.collection : undefined)) { return; } // When removed the collection goes away.
      const index = this.model.collection.indexOf(this.model);
      const size = this.model.collection.size();
      return this.state.set({current: (index === (size - 1))});
    }

    stateEvents() {
      return {'change': this.reRender};
    }

    modelEvents() { // the only prop we expect to change is count.
      return {'change': this.reRender};
    }

    events() {
      return {
        'click .btn.im-state-revert': 'revertToState',
        click(e) { e.preventDefault(); return e.stopPropagation(); }
      };
    }

    revertToState() {
      return this.model.collection.revertTo(this.model);
    }

    postRender() {
      this.$details = this.$('.im-step-details');
      this.$el.toggleClass('im-current-state', this.state.get('current'));
      this.$('.btn[title]').tooltip({placement: 'right'});
      // Only show what has changed.
      if (this.state.get('current')) {
        return this.renderAllSections();
      } else { // Only render the section that changed.
        const title = this.model.get('title');
        switch (title.label) {
          case 'column': return this.renderViews();
          case 'filter': return this.renderConstraints();
          case 'sort order element': return this.renderSortOrder();
          case 'Initial': return null; // ignore
          default: return console.error('Cannot render', title.label);
        }
      }
    }

    renderAllSections() {
      this.renderViews();
      this.renderConstraints();
      return this.renderSortOrder();
    }

    renderViews() {
      return this.renderChild('views', (new SelectListView({collection: this.views})), this.$details);
    }

    renderSortOrder() {
      return this.renderChild('so', (new SortOrderView({collection: this.sortOrder})), this.$details);
    }

    renderConstraints() {
      return this.renderChild('cons', (new ConstraintsView({collection: this.constraints})), this.$details);
    }
  };
  UndoStep.initClass();
  return UndoStep;
})());

class SelectListView extends QueryProperty {
  static initClass() {
  
    this.prototype.summaryLabel = 'undo.ViewCount';
  }
  labelContent(view) { return view.displayName; }
}
SelectListView.initClass();

class SortOrderView extends QueryProperty {
  static initClass() {
  
    this.prototype.summaryLabel = 'undo.OrderElemCount';
  }
  labelContent(oe) { return `${ oe.displayName } ${ oe.direction }`; }
}
SortOrderView.initClass();

const valuesLength = con => M.getText('constraints.NoOfValues', {n: con.values.length});

const idsLength = con => M.getText('constraints.NoOfIds', {n: con.ids.length});

class ConstraintsView extends QueryProperty {
  static initClass() {
  
    this.prototype.summaryLabel = 'undo.ConstraintCount';
  }

  labelContent(con) {
    const parts = (() => { switch (con.CONSTRAINT_TYPE) {
      case 'MULTI_VALUE':
        return [con.displayName, con.op, con.values.length, (valuesLength(con))];
      case 'TYPE':
        return [con.displayName, M.getText('constraints.ISA'), con.typeName];
      case 'IDS':
        return [con.displayName, con.op, (idsLength(con))];
      case 'LOOKUP':
        return [con.displayName, con.op, con.value, M.getText('constraints.LookupIn'), con.extraValue];
      default: // ATTR_VALUE, LIST, LOOP
        return [con.displayName, con.op, con.value];
    } })();

    return parts.join(' ');
  }
}
ConstraintsView.initClass();

