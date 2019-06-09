// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ListTag;
const CoreView = require('../../core-view');
const Templates = require('../../templates');

// A component that manages a single tag.
module.exports = (ListTag = (function() {
  ListTag = class ListTag extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-list-tag label label-primary';
  
      this.prototype.template = Templates.template('list-tag');
    }

    events() {
      return {'click .im-remove': 'removeAndDestroy'};
    }

    // Once rendered, activate the tooltip.
    postRender() {
      return this.activateTooltip();
    }

    // If it has a title - then tooltip it.
    activateTooltip() { return this.$('[title]').tooltip(); }

    // Destroy the tag, remove it from the model, and this view of it from the DOM
    removeAndDestroy() {
      this.model.collection.remove(this.model);
      this.model.destroy();
      return this.$el.fadeOut(400, () => this.remove());
    }
  };
  ListTag.initClass();
  return ListTag;
})());

