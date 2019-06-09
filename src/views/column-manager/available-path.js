/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let AvailablePath;
const _ = require('underscore');
const UnselectedColumn = require('./unselected-column');

const CUTOFF = 900;

module.exports = (AvailablePath = (function() {
  AvailablePath = class AvailablePath extends UnselectedColumn {
    static initClass() {
  
      // a function that will help us find the connected list, without
      // having a reverence to the parent directly.
      this.prototype.parameters = ['findActives'];
  
      this.prototype.restoreTitle = 'columns.AddColumnToSortOrder';
    }

    events() { return _.extend(super.events(...arguments), {
      mousedown: 'onMouseDown',
      dragstart: 'onDragStart',
      dragstop: 'onDragStop'
    }
    ); }

    onMouseDown() {
      return this.fixAppendTo();
    }

    // Cannot be set correctly on init., since when this element is rendered
    // it is likely part of a document fragment, and thus its appendTo
    // will not be available.
    fixAppendTo() {
      this.$el.draggable('option', 'appendTo', this.$el.closest('.well'));
      const modalWidth = this.$el.closest('.modal').width();
      const wide = (modalWidth >= CUTOFF);
      return this.$el.draggable('option', 'axis', (wide ? null : 'y'));
    }

    onDragStart() {
      this.state.set({dragged: this.model.get('path')});
      return this.$el.addClass('ui-dragging');
    }

    onDragStop() {
      this.state.unset('dragged');
      return this.$el.removeClass('ui-dragging');
    }

    postRender() {
      // copied out of bootstrap variables - if only they could be shared!
      // TODO - move to common file.
      const modalWidth = this.$el.closest('.modal').width();
      const wide = (modalWidth >= CUTOFF);
      const index = this.model.collection.indexOf(this.model);
      this.$el.draggable({
        axis: (wide ? null : 'y'),
        connectToSortable: this.findActives(),
        helper: 'clone',
        revert: 'invalid',
        opacity: 0.8,
        cancel: 'i,a,button',
        zIndex: 1000
      });

      return this.$('[title]').tooltip({placement: (index === 0 ? 'bottom' : 'top')});
    }
  };
  AvailablePath.initClass();
  return AvailablePath;
})());
