// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let DropDownColumnSummary;
const _ = require('underscore');

const FacetView = require('../facets/facet-view');
const PathModel = require('../../models/path');
const {ignore} = require('../../utils/events');

const NO_QUERY = 'No query in call to new DropDownColumnSummary';
const BAD_MODEL = 'No PathModel in call to new DropDownColumnSummary';

// Thin wrapper that converts from the ColumnHeader calling convention
// of {query :: Query, model :: HeaderModel} to the FacetView constructor
// of {query :: Query, view :: PathInfo}.
module.exports = (DropDownColumnSummary = class DropDownColumnSummary extends FacetView {

  className() { return `${ super.className(...arguments) } im-dropdown-summary`; }

  constructor({query, model}) {
    if (!query) { throw new Error(NO_QUERY); }
    if (!(model instanceof PathModel)) { throw new Error(BAD_MODEL); }
    super({query, view: model.pathInfo()});
  }

  events() { return _.extend(super.events(...arguments), {click: ignore}); }

  postRender() {
    super.postRender(...arguments);
    // there is one situation where this view is mounted, not appended.
    return this.$el.addClass(this.className());
  }
});
