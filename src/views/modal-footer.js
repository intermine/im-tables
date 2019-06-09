// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ModalFooter;
const _ = require('underscore');
const CoreView = require('../core-view');
const Templates = require('../templates');

const defaultData = () =>
  ({
    error: null,
    exportLink: null,
    disabled: false,
    disabledReason: null
  })
;

module.exports = (ModalFooter = (function() {
  ModalFooter = class ModalFooter extends CoreView {
    static initClass() {
    
      this.prototype.tagName = 'div';
  
      this.prototype.className = 'modal-footer';
  
      // model properties we read in the template.
      // The error is a blocking error to display to the user, which will disable
      // the main action.
      // The href is used by dialogues that perform export using GETs to URLs that support
      // disposition = attachment, which browsers will perform as a download if this href is
      // used in a link.
      this.prototype.RERENDER_EVENT = 'change:error change:exportLink';
  
      this.prototype.parameters = ['template', 'actionNames', 'actionIcons'];
    }

    getData() { return _.extend(defaultData(), this.actionNames, this.actionIcons, super.getData(...arguments)); }

    postRender() {
      return this.$('[title]').tooltip();
    }
  };
  ModalFooter.initClass();
  return ModalFooter;
})());

