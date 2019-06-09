// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let FacetRow;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Templates = require('../../templates');

const Checkbox = require('../../core/checkbox');
const RowSurrogate = require('./row-surrogate');

require('../../messages/summary');

const bool = x => !!x;

// Row in the drop down summary.
module.exports = (FacetRow = (function() {
  FacetRow = class FacetRow extends CoreView {
    static initClass() {
  
      // Not all of these are expected to actually change,
      // but these are the things the template depends on.
      this.prototype.RERENDER_EVENT = 'change:count change:item change:symbol change:share';
  
      this.prototype.tagName = "tr";
  
      this.prototype.className = "im-facet-row";
    
      // The template, and data used by templates
   
      this.prototype.template = Templates.template('facet_row');
    }

    modelEvents() {
      return {
        "change:visible": this.onChangeVisibility,
        "change:hover": this.onChangeHover,
        "change:selected": this.onChangeSelected
      };
    }

    // Invariants

    invariants() { return {modelHasCollection: "No collection on model"}; }

    modelHasCollection() { return ((this.model != null ? this.model.collection : undefined) != null); }

    getData() {
      const max = this.model.collection.getMaxCount();
      const ratio = this.model.get('count') / max;
      const opacity = ((ratio / 2) + 0.5).toFixed(); // opacity ranges from 0.5 - 1
      const percent = (ratio * 100).toFixed(); // percentage is int from 0 - 100

      return _.extend(super.getData(...arguments), {percent, opacity, max});
    }

    onRenderError(e) { return console.error(e); }

    // Subviews and interactions with the DOM.

    postRender() {
      this.addCheckbox();
      this.onChangeVisibility();
      this.onChangeHover();
      return this.onChangeSelected();
    }

    addCheckbox() {
      return this.renderChildAt('.checkbox', (new Checkbox({model: this.model, attr: 'selected'})));
    }

    onChangeVisibility() { return this.$el.toggleClass('im-hidden', !this.model.get("visible")); }

    onChangeHover() { // can be hovered in the graph.
      const isHovered = bool(this.model.get('hover'));
      this.$el.toggleClass('hover', isHovered);
      if (isHovered) {
        return this.showSurrogateUnlessVisible();
      } else {
        return this.removeSurrogate();
      }
    }

    onChangeSelected() { return this.$el.toggleClass('im-selected', this.model.get('selected')); }

    removeSurrogate() { return this.removeChild('surrogate'); }

    showSurrogateUnlessVisible() {
      this.removeSurrogate(); // to be sure
      if (!this.isVisible()) {
        let newTop;
        const above = this.isAbove();
        const surrogate = new RowSurrogate({model: this.model, above});
        const $s = surrogate.$el;
        const table = this.getTable();
        this.renderChild('surrogate', surrogate, table);
        return newTop = above ?
          $s.css({top: table.scrollTop()})
        :
          $s.css({bottom: 0 - table.scrollTop()});
      }
    }

    getTable() { return this.$el.closest('.im-item-table'); }

    // Events definitions and their handlers.

    events() { return {'click': 'handleClick'}; }

    handleClick(e) {
      e.stopPropagation();
      return this.model.toggle('selected');
    }

    isBelow() {
      const parent = this.getTable();
      return (this.$el.offset().top + this.$el.outerHeight()) > (parent.offset().top + parent.outerHeight());
    }

    isAbove() {
      const parent = this.getTable();
      return this.$el.offset().top < parent.offset().top;
    }

    isVisible() { return !(this.isAbove() || this.isBelow()); }
  };
  FacetRow.initClass();
  return FacetRow;
})());
