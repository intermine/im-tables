/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let TagsApology;
const _ = require('underscore');
const CoreView = require('../../core-view');
const Templates = require('../../templates');

// This view uses the lists messages bundle.
require('../../messages/lists');

// A component that displays an apology if there are
// no tags to show.
module.exports = (TagsApology = (function() {
  TagsApology = class TagsApology extends CoreView {
    static initClass() {
  
      this.prototype.template = Templates.template('list-tags-apology');
    }

    collectionEvents() {
      return {'add remove reset': this.reRender};
    }

    getData() { return _.extend(super.getData(...arguments), {hasTags: this.collection.size()}); }
  };
  TagsApology.initClass();
  return TagsApology;
})());

