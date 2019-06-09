/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SummaryItemsControls;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Templates = require('../../templates');
const Messages = require('../../messages');

require('../../messages/summary');

const bool = x => !!x;

const negateOps = function(ops) {
  const ret = {};
  ret.multi = ops.multi === 'ONE OF' ? 'NONE OF' : 'ONE OF';
  ret.single = ops.single === '==' ? '!=' : '==';
  ret.absent = ops.absent === 'IS NULL' ? 'IS NOT NULL' : 'IS NULL';
  return ret;
};

// Null safe event ignorer, and blocker.
const IGNORE = function(e) { if (e != null) {
  e.preventDefault();
  return e.stopPropagation();
} };

const BASIC_OPS = {
  single: '==',
  multi: 'ONE OF',
  absent: 'IS NULL'
};

// One day tab will be expunged, one day...
const SUMMARY_FORMATS = {
  tab: 'tsv',
  csv: 'csv',
  xml: 'xml',
  json: 'json'
};

// The minimum number of values a constraint needs to have before we will
// optimise it to its inverse to avoid very large constraints.
const MIN_VALS_OPTIMISATION = 10;

// These get their own view as they have a different re-render
// schedule to that of the main summary.
module.exports = (SummaryItemsControls = (function() {
  SummaryItemsControls = class SummaryItemsControls extends CoreView {
    static initClass() {
  
      this.prototype.RERENDER_EVT = 'change';
  
      // The template, and data used by templates
  
      this.prototype.template = Templates.template('summary_items_controls');
  
      this.prototype.downloadPopoverTemplate = Templates.template('download_popover');
    }

    initialize() {
      super.initialize(...arguments);
      return this.listenTo(this.model.items, 'change:selected', this.reRender);
    }

    // Invariants

    invariants() {
      return {
        viewIsAttribute: `No view, or view not Attribute: ${ this.view }`,
        hasCollection: "No collection"
      };
    }

    viewIsAttribute() { return __guardMethod__(this.model != null ? this.model.view : undefined, 'isAttribute', o => o.isAttribute()); }

    hasCollection() { return ((this.model != null ? this.model.items : undefined) != null); }

    getData() {
      const anyItemSelected = bool(this.model.items.findWhere({selected: true}));
      return _.extend(super.getData(...arguments), {anyItemSelected});
    }

    // Subviews and post-render actions.

    postRender() {
      this.activateTooltips();
      return this.activatePopovers();
    }

    activateTooltips() {
      return this.$btns = this.$('.btn[title]').tooltip({placement: 'top', container: this.el});
    }

    activatePopovers() {
      return this.$('.im-download').popover({
        placement: 'top',
        html: true,
        container: this.el,
        title: Messages.getText('summary.DownloadFormat'),
        content: this.getDownloadPopover(),
        trigger: 'manual'
      });
    }

    // Returns the HTML for the download-popover.
    getDownloadPopover() { return this.downloadPopoverTemplate(_.extend(this.getBaseData(), {
      query: this.model.query,
      path: this.model.view.toString(),
      formats: SUMMARY_FORMATS
    }
    )
    ); }

    // Event definitions and their handlers.

    events() {
      return {
        'click .im-export-summary': 'exportSummary',
        'click': 'hideTooltips',
        'click .btn-cancel': 'unsetSelection',
        'click .btn-toggle-selection': 'toggleSelection',
        'click .im-filter-group .dropdown-toggle': 'toggleDropdown',
        'click .im-download': 'toggleDownloadPopover',
        'click .im-filter-in': _.bind(this.addConstraint, this, BASIC_OPS),
        'click .im-filter-out': _.bind(this.addConstraint, this, negateOps(BASIC_OPS))
      };
    }

    exportSummary(e) {
      // The only purpose of this is to reinstate the default <a> click behaviour which is
      // being swallowed by another click handler. This is really dumb, but for future
      // reference this is how you block someone else's click handlers.
      e.stopImmediatePropagation();
      return true;
    }

    hideTooltips() { return (this.$btns != null ? this.$btns.tooltip('hide') : undefined); }

    unsetSelection(e) { return this.changeSelection(item => item.set({selected: false})); }

    toggleSelection(e) { return this.changeSelection(function(x) { if (x.get('visible')) { return x.toggle('selected'); } }); }

     // The following is due to the practice of bootstrap forcing
     // all dropdowns closed when another opens, preventing nested
     // dropdowns, which is what we have here.
    toggleDropdown() {
      return this.$('.im-filter-group').toggleClass('open');
    }

    // Open (or close) the download popover
    toggleDownloadPopover() {
      return this.$('.im-download').popover('toggle');
    }

    addConstraint(ops, e) {
      let item;
      IGNORE(e);
      const vals = ((() => {
        const result = [];
        for (item of Array.from(this.model.items.where({selected: true}))) {           result.push(item.get('item'));
        }
        return result;
      })());
      const unselected = this.model.items.where({selected: false});

      if (unselected.length === 0) {
        return this.model.set({error: (new Error('All items are selected'))});
      }

      const anyIsNull = _.any(vals, v => v == null);

      // If we know all the possible values, and there are more selected than
      // un-selected values (above a certain cut-off), then make the smaller
      // constraint. This means if a user selects 95 of 100 values, the resulting
      // constraint will only hold 5 values.
      if ((!anyIsNull) && this.model.hasAll() && (MIN_VALS_OPTIMISATION > vals.length && vals.length > unselected.length)) {
        return this.constrainTo((negateOps(ops)), ((() => {
          const result1 = [];
          for (item of Array.from(unselected)) {             result1.push(item.get('item'));
          }
          return result1;
        })()));
      } else { // add the constraint as is.
        return this.constrainTo(ops, vals);
      }
    }

    // The new constraint is either a multi-value constraint, a single-value constraint,
    // or a null constraint. Helper for addConstraint
    constrainTo(ops, vals) {
      if (!(vals != null ? vals.length : undefined)) {
        return this.model.set({error: (new Error('No values are selected'))});
      }
      const q = this.model.query;
      const path = this.model.view.toString();
      const [val] = Array.from(vals);
      const newCon = (() => { switch (false) {
        case !(vals.length > 1): return {op: ops.multi, values: vals};
        case (val == null): return {op: ops.single, value: String(val)};
        default: return {op: ops.absent};
      } })();

      // use an existing constraint, if it makes sense to do so.
      if ((!/or/.test(q.constraintLogic)) && (newCon.op === 'ONE OF')) {
        let existing;
        if (existing = (_.findWhere(q.constraints, {path, op: 'ONE OF'}))) {
          // This should probably be in imjs.
          existing.values = newCon.values;
          return q.trigger('change:constraints', q.constraints);
        }
      }
      // Couldn't replace - add instead.
      return q.addConstraint(_.extend(newCon, {path}));
    }

    // Set the selection state for the items - helper for unsetSelection, toggleSelection
    changeSelection(f) {
      // The function is deferred so that any rendering that happens due to it
      // does not block iterating over the items.
      return this.model.items.each(item => _.defer(f, item));
    }
  };
  SummaryItemsControls.initClass();
  return SummaryItemsControls;
})());


function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}