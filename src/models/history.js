// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let History;
const _ = require('underscore');
const Collection = require('../core/collection');
const StepModel = require('./step');

module.exports = (History = (function() {
  History = class History extends Collection {
    static initClass() {
  
      this.prototype.model = StepModel;
  
      this.prototype.currentQuery = null;
  
      // Monotonically increasing revision counter.
      this.prototype.currentStep = 0;
  
      // Sort by revision.
      // (Not really needed, but good to be explicit).
      this.prototype.comparator = 'revision';
    }

    initialize() {
      super.initialize(...arguments);
      this.listenTo(this, 'remove', this.unwatch);
      return this.listenTo(this, 'add', this.watch);
    }

    // The current query is the query of the last (most
    // recent) state.
    getCurrentQuery() { return this.currentQuery; }

    setCurrentQuery(m) {
      return this.currentQuery = m.get('query').clone();
    }

    // Stop listening to changes to the current query,
    // or the given query.
    unwatch(model) {
      let left;
      const q = ((left = (model != null ? model.get('query') : undefined)) != null ? left : this.getCurrentQuery());
      if (q == null) { return; } // Nothing to stop listening to!
      return this.stopListening(q);
    }

    watch(m) {
      this.setCurrentQuery(m);
      const q = this.getCurrentQuery();
      if (q == null) { return; }
      this.listenTo(q, "change:constraints", this.onChangeConstraints);
      this.listenTo(q, "change:views", this.onChangeViews);
      this.listenTo(q, "change:joins", this.onChangeJoins);
      this.listenTo(q, "change:sortorder", this.onChangeSortOrder);
      this.listenTo(q, "change:logic", this.onChangeLogic);
      return this.listenTo(q, "undo", this.popState);
    }

    // TODO - get rid of labels - they are pointless. Use the query prop instead

    onChangeConstraints() {
      return this.onChange('constraints', 'filter', cons => _.map(cons, JSON.stringify));
    }

    onChangeViews() {
      return this.onChange('views', 'column');
    }

    onChangeJoins() {
      return this.onChange('joins', 'join', joins => _.map(joins, (style, path) => `${ path }:${ style }`));
    }

    onChangeSortOrder() {
      return this.onChange('sortOrder', 'sort order element', so => _.map(so, JSON.stringify));
    }

    onChangeLogic() {
      return this.onChange('constraintLogic', 'constraint logic element', function(expr) {
        let left;
        return (left = (expr != null ? expr.match(/([A-Z]+)/) : undefined)) != null ? left : [];
    });
    }

    // Inform clients that the current query is different
    triggerChangedCurrent() {
      return this.trigger('changed:current', this.last());
    }

    // Handle a change event, analysing what has changed
    // and adding a step that records that change.
    onChange( prop, label, f ) {
      if (f == null) { f = x => x; }
      const query = this.currentQuery;
      const prev = this.last().get('query');
      const xs = f(prev[prop]);
      const ys = f(query[prop]);
      const was = xs.length;
      const now = ys.length;
      const n = Math.abs(was - now);

      const verb = (() => { switch (false) {
        case !(was < now): return 'Added';
        case !(was > now): return 'Removed';
        case now !== _.union(xs, ys).length: return 'Rearranged';
        default: return 'Changed';
      } })();

      return this.addStep(verb, n, label, query);
    }

    // Set the root query of this history.
    setInitialState(q) {
      if (this.size()) { this.reset(); }
      return this.addStep(null, null, 'Initial', q);
    }

    // Add a new state to the history, setting it as the new
    // current query.
    addStep(verb, number, label, query) {
      const was = this.currentQuery;
      const now = query.clone();
      this.unwatch(); // unbind listeners for the current query.
      this.add({
        query: now,
        revision: this.currentStep++,
        title: {
          verb,
          number,
          label
        }
      });
      if (was != null) {
        was.trigger('replaced:by', now);
      }
      return this.triggerChangedCurrent();
    }

    // Revert to the state before the most recent one.
    popState() { return this.revertToIndex(-2); }

    revertToIndex(index) {
      if (index < 0) { index = (this.length + index); }
      const now = this.at(index);
      return this.revertTo(now);
    }

    revertTo(now) {
      if (!this.contains(now)) { throw new Error('State not in history'); }
      const was = this.getCurrentQuery();
      const revision = now.get('revision');
      // Remove everything after the target
      while (this.last().get('revision') > revision) {
        this.pop();
      }
      this.watch(now); // Nothing added, but the current query has changed.
      if (was != null) {
        was.trigger('replaced:by', now.get('query'));
      }
      return this.triggerChangedCurrent();
    }
  };
  History.initClass();
  return History;
})());

