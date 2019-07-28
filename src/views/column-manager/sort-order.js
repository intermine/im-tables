// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SortOrderEditor;
const _ = require('underscore');

const CoreView = require('../../core-view');
const CoreModel = require('../../core-model');
const Templates = require('../../templates');
const HandlesDOMReSort = require('../../mixins/handles-dom-resort');

const AvailablePath = require('./available-path');
const OrderElement = require('./order-element');

const activeId = model => `active_${ model.get('id') }`;
const inactiveId = model => `inactive_${ model.get('id') }`;

module.exports = (SortOrderEditor = (function() {
  SortOrderEditor = class SortOrderEditor extends CoreView {
    static initClass() {
  
      this.include(HandlesDOMReSort);
  
      this.prototype.parameters = ['collection', 'query', 'availableColumns'];
  
      this.prototype.className = 'im-sort-order-editor';
  
      this.prototype.template = Templates.template('column-manager-sort-order-editor');
    }

    getData() { return _.extend(super.getData(...arguments), {available: this.availableColumns.size()}); }

    collectionEvents() {
      return {
        'add remove': this.reRender,
        'sort': this.resortSortOrder,
        'remove': this.makeAvailable
      };
    }

    initialize() {
      super.initialize(...arguments);
      this.dragState = new CoreModel;
      this.listenTo(this.availableColumns, 'sort add remove', this.resortAvailable);
      return this.listenTo(this.availableColumns, 'remove', this.addToSortOrder);
    }

    currentSortOrder() {
      return this.collection.map(m => `${ m.get('path') } ${ m.get('direction') }`)
                 .join(' ');
    }

    postRender() {
      // First we render the sort-order.
      this.resortSortOrder();
      // Then we activate the drag/drop/sort-ables - this must be done
      // before we render the available paths, since they need a reference
      // to the active paths, which is created in ::activateSortables
      this.activateSortables();
      // render the available paths.
      this.resortAvailable();
      return this.setAvailableHeight();
    }

    activateSortables() {
      const active = this.$('.im-active-oes');
      // copied out of bootstrap variables - if only they could be shared!
      const cutoff = 900;
      const modalWidth = this.$el.closest('.modal').width();
      const wide = (modalWidth >= cutoff);

      if (this.collection.size()) {
        return this.$actives = active.sortable({
          placeholder: 'im-view-list-placeholder',
          opacity: 0.6,
          cancel: 'i,a,button',
          axis: (wide ? null : 'y'),
          appendTo: this.el
        });
      } else {
        return this.$droppable = this.$('.im-empty-collection').droppable({
          accept: '.im-selected-column',
          activeClass: 'im-can-add-column',
          hoverClass: 'im-will-add-column'
        });
      }
    }

    removeAllChildren() {
      if (this.$actives != null) {
        this.$actives.sortable('destroy');
      }
      if (this.$droppable != null) {
        this.$droppable.droppable('destroy');
      }
      this.$droppable = null;
      this.$actives = null;
      return super.removeAllChildren(...arguments);
    }

    events() {
      return {
        'drop .im-empty-collection': 'addSortElement',
        'sortupdate .im-active-oes': 'onDOMResort'
      };
    }

    onDOMResort(e, ui) {
      let path;
      if (path = this.dragState.get('dragged')) {
        const model = this.availableColumns.findWhere({path});
        const indexAt = ui.item.prevAll().length;
        this.addToSortOrder(model, indexAt);
        return this.dragState.unset('dragged');
      } else {
        return this.setChildIndices(activeId);
      }
    }

    makeAvailable(active) {
      return this.availableColumns.add(this.query.makePath(active.get('path')));
    }

    findAvailable(el) { return this.availableColumns.find(m => {
      return __guard__(this.children[inactiveId(m)], x => x.el) === el;
    }); }

    addSortElement(e, ui) {
      const $el = ui.draggable;
      const available = this.findAvailable($el[0]);
      return this.addToSortOrder(available);
    }

    addToSortOrder(availableColumnModel, atIndex) {
      const path = this.query.makePath(availableColumnModel.get('path'));
      const oe = {id: (String(path)), path};
      const sizeBeforeAdd = this.collection.size();
      // remove from collection, etc.
      availableColumnModel.destroy();
      this.collection.add(oe);
      if ((atIndex != null) && (atIndex < sizeBeforeAdd)) {
        const toBump = this.collection.filter(m => m.get('index') >= atIndex);
        const added = this.collection.last();
        for (let b of Array.from(toBump)) {
          b.swap('index', idx => idx + 1);
        }
        return added.set({index: atIndex});
      }
    }

    // Cleanest way I could think of to do this.
    resortAvailable() { if (this.rendered) {
      const frag = global.document.createDocumentFragment();
      this.availableColumns.each(model => {
        return this._renderAvailable(model, frag);
      });
      return this.$('.im-available-oes').html(frag);
    } }

    _renderAvailable(model, frag) {
      const name = inactiveId(model);
      const findActives = () => this.$actives;
      const view = new AvailablePath({model, findActives, state: this.dragState});
      return this.renderChild(name, view, frag);
    }

    resortSortOrder() { if (this.rendered) {
      const frag = global.document.createDocumentFragment();
      this.collection.each(model => {
        return this.renderChild((activeId(model)), (new OrderElement({model})), frag);
      });
      return this.$('.im-active-oes').html(frag);
    } }

    setAvailableHeight() {
      return this.$('.im-rubbish-bin').css({'max-height': Math.max(200, (this.$el.closest('.modal').height() - 450))});
    }

    remove() {
      this.dragState.destroy();
      return super.remove(...arguments);
    }
  };
  SortOrderEditor.initClass();
  return SortOrderEditor;
})());

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}