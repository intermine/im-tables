// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ItemDetails;
const _ = require('underscore');

const Templates = require('../../templates');
const CoreView = require('../../core-view');
const {ignore} = require('../../utils/events');

const ITEMS = Templates.template('cell-preview-items');
const REFERENCE = Templates.template('cell-preview-reference');
const ATTR = Templates.template('cell-preview-attribute');

module.exports = (ItemDetails = (function() {
  ItemDetails = class ItemDetails extends CoreView {
    static initClass() {
  
      this.prototype.tagName = 'table';
  
      this.prototype.className = 'im-item-details table table-condensed table-bordered';
  
      this.prototype.template = ITEMS;
    
      this.prototype.renderREF = REFERENCE;
    }

    collectionEvents() {
      return {
        sort: this.reRender,
        add: this.addDetail
      };
    }

    events() {
      return {'click .im-too-long': this.revealLongField};
    }

    postRender() { return this.collection.each(details => this.addDetail(details)); }

    addDetail(details) {
      return this.$el.append(this[`render${details.get('fieldType')}`](details.toJSON()));
    }

    renderATTR(data) { return ATTR(_.extend(this.getBaseData(), data)); }

    revealLongField(e) {
      ignore(e);
      const $tooLong = this.$('.im-too-long');
      const $overSpill = this.$('.im-overspill');
      $tooLong.remove();
      return $overSpill.slideDown(250);
    }
  };
  ItemDetails.initClass();
  return ItemDetails;
})());

