// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let LargeTableDisuader;
const _  = require('underscore');

const Modal = require('../modal');

const {large_table_disuader} = require('../../templates');

// Definitions of the actions this modal returns
const Actions = {
  ACCEPT: 'accept', // The user accepted the size, despite the warning
  CONSTRAIN: 'constrain', // The user wants to add a filter.
  BACK: 'back', // The user wants to go back a page.
  FWD: 'forward', // The user wants to go forward a page.
  EXPORT: 'export', // The user wants to download data.
  DISMISS: 'dismiss' // The user does not want to change the page size.
};

// modal dialogue that presents user with range of other options instead of
// large tables, and lets them choose one.
module.exports = (LargeTableDisuader = (function() {
  LargeTableDisuader = class LargeTableDisuader extends Modal {
    static initClass() {
  
      this.prototype.template = _.template(large_table_disuader);
    }

    className() { return `im-page-size-sanity-check fade ${super.className(...arguments)}`; }

    act() { 
      return this.resolve("accept");
    }

    events() { return _.extend(super.events(...arguments), {
      'click .btn-primary':         (() => this.resolve(Actions.ACCEPT)),
      'click .add-filter-dialogue': (() => this.resolve(Actions.CONSTRAIN)),
      'click .page-backwards':      (() => this.resolve(Actions.BACK)),
      'click .page-forwards':       (() => this.resolve(Actions.FWD)),
      'click .download-menu':       (() => this.resolve(Actions.EXPORT))
    }
    ); }
  };
  LargeTableDisuader.initClass();
  return LargeTableDisuader;
})());
