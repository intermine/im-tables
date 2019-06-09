/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SelectListEditor;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Templates = require('../../templates');
const Collection = require('../../core/collection');

const HandlesDOMReSort = require('../../mixins/handles-dom-resort');

const SelectedColumn = require('./selected-column');
const UnselectedColumn = require('./unselected-column');
const ColumnChooser = require('./path-chooser');

const childId = model => `path_${ model.get('id') }`;
const binnedId = model => `expath_${ model.get('id') }`;
const incr = x => x + 1;

module.exports = (SelectListEditor = (function() {
  SelectListEditor = class SelectListEditor extends CoreView {
    static initClass() {
  
      this.include(HandlesDOMReSort);
  
      this.prototype.parameters = ['query', 'collection', 'rubbishBin'];
  
      this.prototype.className = 'im-select-list-editor';
  
      this.prototype.template = Templates.template('column-manager-select-list');
    }

    getData() { return _.extend(super.getData(...arguments), {hasRubbish: this.rubbishBin.size()}); }

    initialize() {
      super.initialize(...arguments);
      return this.listenTo(this.rubbishBin, 'remove', this.restoreView);
    }

    initState() {
      return this.state.set({adding: false});
    }

    collectionEvents() {
      return {
        'remove': 'moveToBin',
        'add remove': 'reRender'
      };
    }

    events() {
      return {
        'drop .im-rubbish-bin': 'onDragToBin',
        'sortupdate .im-active-view': 'onOrderChanged',
        'click .im-add-view-path': 'setAddingTrue'
      };
    }

    stateEvents() {
      return {'change:adding': 'onChangeMode'};
    }

    setAddingTrue() { return this.state.set({adding: true}); }

    onDragToBin(e, ui) { return ui.draggable.trigger('binned'); }

    moveToBin(model) {
      this.rubbishBin.add(this.query.makePath(model.get('path')));
      return this.reIndexFrom(model.get('index'));
    }

    reIndexFrom(idx) {
      return __range__(idx, this.collection.size(), true).map((i) =>
        __guard__(this.collection.at(i), x => x.set({index: i})));
    }

    restoreView(model) { return this.collection.add(this.query.makePath(model.get('path'))); }

    onChangeMode() { if (this.rendered) {
      if (this.state.get('adding')) {
        this.$('.im-removal-and-rearrangement').hide();
        this.$('.im-addition').show();
        return this.renderPathChooser();
      } else {
        this.$('.im-removal-and-rearrangement').show();
        this.$('.im-addition').hide();
        return this.removeChild('columnChooser');
      }
    } }

    renderPathChooser() {
      const columns = new ColumnChooser({query: this.query, collection: this.collection});
      this.listenTo(columns, 'done', () => this.state.set({adding: false}));
      return this.renderChild('columnChooser', columns, this.$('.im-addition'));
    }

    onOrderChanged(e, ui) {
      if (ui.sender != null) {
        return this.restoreFromBin(ui.item);
      } else {
        return this.onDOMResort();
      }
    }

    getInsertPoint($el) {
      const addedAfter = $el.prev();
      const kids = this.children;

      const prevModel = this.collection.find(function(m) {
        const active = kids[childId(m)];
        return active.el === addedAfter[0];});

      if ((prevModel == null)) {
        return 0; // Nothing in front, we are first, yay.
      } else { // We are added at the index after the one in front.
        return prevModel.get('index') + 1;
      }
    }

    getRestoredModel($el) { return this.rubbishBin.find(m => {
      const binned = this.children[binnedId(m)];
      return (binned != null ? binned.el : undefined) === $el[0];
  }); }

    // jQuery UI sortable does not give us indexes - so we have
    // to work those out ourselves, very annoyingly.
    restoreFromBin($el) {
      const kids = this.children;                  //:: {string -> View}
      const preAddSize = this.collection.size();   //:: int
      const addedAt = this.getInsertPoint($el);     //:: int
      const toRestore = this.getRestoredModel($el); //:: Model?

      // Destroy the binned view - this triggers the model's
      // removal from the bin, which triggers restoreView - so
      // once it returns, the path has been added back to the view.
      if (toRestore != null) {
        toRestore.destroy();
      } else {
        console.error('could not find model for:', $el);
        return; // Something went wrong, nothing we can do.
      }
      // Added at end - our work is done.
      if (addedAt === preAddSize) { return; }

      // At this point, the path has been restored - but
      // we still need to put it in the correct place.
      // first find the models we need to bump to the right.
      const toBump = (__range__(addedAt, preAddSize, false).map((i) => this.collection.at(i)));
      // The one we added is always the last.
      const added = this.collection.last();
      // Bump the ones after us to the right.
      for (let m of Array.from(toBump)) {
        m.swap('index', incr);
      }
      // Set the index of the newly added model.
      added.set({index: addedAt});
      // OK, so the state is correct, we just have to put the new
      // element in the right place, which is done with this horror:
      // While this is slightly ugly, it is much more efficient
      // than the alternative, which is to reposition on the sort
      // event, since this is O(1), not O(n*n).
      return kids[childId(added)].$el.insertBefore(kids[childId(toBump[0])].el);
    }

    onDOMResort() { return this.setChildIndices(childId); }

    postRender() {
      const columns = this.$('.im-active-view');
      const binnedCols = this.$('.im-removed-view');

      //TODO: cut-and paste from sort-order.coffee - move to separate file.
      const cutoff = 900;
      const modalWidth = this.$el.closest('.modal').width();
      const wide = (modalWidth >= cutoff);

      // By now backbone should have attached a collection attribute
      // to the models, but it either hasn't or its been stripped upstream.
      // TODO: figure out why and remove the following loop
      this.collection.each(model => { return model.collection = this.collection; });
      this.rubbishBin.each(model => { return model.collection = this.rubbishBin; });

      this.collection.each(model => {
        return this.renderChild((childId(model)), (new SelectedColumn({model})), columns);
      });
      this.rubbishBin.each(model => {
        return this.renderChild((binnedId(model)), (new UnselectedColumn({model})), binnedCols);
      });

      columns.sortable({
        placeholder: 'im-view-list-placeholder',
        opacity: 0.6,
        cancel: 'i,a,button',
        axis: (wide ? null : 'y'),
        appendTo: this.el
      });

      this.$('.im-removed-view').sortable({
        placeholder: 'im-view-list-placeholder',
        connectWith: columns,
        opacity: 0.6,
        cancel: 'i,a,button',
        axis: (wide ? null : 'y'),
        appendTo: this.el
      });

      this.$('.im-rubbish-bin').droppable({
        accept: '.im-selected-column',
        activeClass: 'im-can-remove-column',
        hoverClass: 'im-will-remove-column'
      });

      return this.onChangeMode(); // make sure we are in the right mode.
    }

    removeAllChildren() {
      if (this.rendered) {
        this.$('.im-active-view').sortable('destroy');
        this.$('.im-removed-view').sortable('destroy');
        this.$('.im-rubbish-bin').droppable('destroy');
      }
      return super.removeAllChildren(...arguments);
    }
  };
  SelectListEditor.initClass();
  return SelectListEditor;
})());

function __range__(left, right, inclusive) {
  let range = [];
  let ascending = left < right;
  let end = !inclusive ? right : ascending ? right + 1 : right - 1;
  for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
    range.push(i);
  }
  return range;
}
function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}