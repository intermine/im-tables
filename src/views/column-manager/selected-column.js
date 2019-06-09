// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SelectedColumn;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Collection = require('../../core/collection');
const Templates = require('../../templates');

const PathModel = require('../../models/path');

const {ignore} = require('../../utils/events');

const decr = i => i - 1;
const incr = i => i + 1;

const TEMPLATE_PARTS = [
  'column-manager-path-remover',
  'column-manager-position-controls',
  'column-manager-path-name'
];

// (*) Note that when we use the buttons to re-arrange, we do the swapping in
// the event handlers. This is ugly, since we are updating the model _and_ the
// DOM in the same method, rather than having the DOM reflect the model.
// However, the reason for this is as follows: there are two ways to rearrange
// the view - dragging or button clicks. Dragging does not need a re-render,
// just a model update, which is performed in the parent component; Button
// clicks don't need a re-render as such, just a re-arrangement, but
// re-arranging on change:index would cause re-renders when the model is updated
// after drag, causing flicker. Also, we don't really _need_ to re-render the
// whole parent, just swap two neighbouring elements. Since this is easy to do,
// it makes sense to do it here.
//
// As for the moveUp/moveDown methods - these are only available when the view
// is not first/last, this they are null safe with regards to prev/next models.
module.exports = (SelectedColumn = (function() {
  SelectedColumn = class SelectedColumn extends CoreView {
    static initClass() {
  
      this.prototype.Model = PathModel;
  
      this.prototype.tagName = 'li';
  
      this.prototype.className = 'list-group-item im-selected-column';
  
      this.prototype.template = Templates.templateFromParts(TEMPLATE_PARTS);
  
      this.prototype.removeTitle = 'columns.RemoveColumn';
    }

    getData() {
      const isLast = (this.model === this.model.collection.last());
      return _.extend(super.getData(...arguments), {removeTitle: this.removeTitle, isLast, parts: (this.parts.pluck('part'))});
    }

    initialize() {
      super.initialize(...arguments);
      this.parts = new Collection;
      this.listenTo(this.parts, 'add remove reset', this.reRender);
      this.resetParts();
      return this.listenTo(this.model.collection, 'sort', this.onCollectionSorted);
    }

    modelEvents() {
      return {
        destroy: this.stopListeningTo,
        'change:parts': this.resetParts
      };
    }

    stateEvents() {
      return {'change:fullPath': this.setFullPathClass};
    }

    onCollectionSorted() { return this.reRender(); }

    resetParts() { return this.parts.reset(Array.from(this.model.get('parts')).map((part, id) => ({part, id}))); }

    postRender() {
      // Activate tooltips.
      return this.$('[title]').tooltip({container: this.$el});
    }

    events() {
      return {
        'click .im-remove-view': 'removeView',
        'click .im-move-up': 'moveUp',
        'click .im-move-down': 'moveDown',
        'click': 'toggleFullPath',
        'binned': 'removeView'
      };
    }

    toggleFullPath() { return this.state.toggle('fullPath'); }

    // Move this view element to the right.
    moveDown(e) {
      ignore(e);
      const next = this.model.collection.at(incr(this.model.get('index')));
      next.swap('index', decr);
      this.model.swap('index', incr);
      return this.$el.insertAfter(this.$el.next()); // this is ugly, but see *
    }

    // Move this view element to the left.
    moveUp(e) {
      ignore(e);
      const prev = this.model.collection.at(decr(this.model.get('index')));
      prev.swap('index', incr);
      this.model.swap('index', decr);
      return this.$el.insertBefore(this.$el.prev()); // this is ugly, but see *
    }

    setFullPathClass() {
      return this.$el.toggleClass('im-full-path', this.state.get('fullPath'));
    }

    removeView(e) {
      ignore(e);
      this.model.collection.remove(this.model);
      return this.model.destroy();
    }
  };
  SelectedColumn.initClass();
  return SelectedColumn;
})());
