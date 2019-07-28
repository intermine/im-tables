// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let CountsTitle;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Messages = require('../../messages');

Messages.setWithPrefix('preview',
  {RelatedItemsHeading: 'Related Items'});

module.exports = (CountsTitle = (function() {
  CountsTitle = class CountsTitle extends CoreView {
    static initClass() {
  
      this.prototype.tagName = 'h4';
    }

    collectionEvents() { return {'add remove reset': this.setVisibility}; }

    setVisibility() { return this.$el.toggleClass('im-hidden', this.collection.isEmpty()); }

    template() { return _.escape(Messages.getText('preview.RelatedItemsHeading')); }

    postRender() { return this.setVisibility(); }
  };
  CountsTitle.initClass();
  return CountsTitle;
})());

