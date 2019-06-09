// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {Promise} = require('es6-promise');

module.exports = function(Base) {

  return {
    parameters: ['query', 'path'],

    className() { return Base.prototype.className.call(this) + ' im-from-path'; },

    // :: -> Promise<Query>
    getQuery() { return Promise.resolve(this.query.selectPreservingImpliedConstraints([this.path])); },

    // :: -> Promise<int>
    fetchCount() {
      return this.query.summarise(this.path)
            .then(({stats: {uniqueValues}}) => uniqueValues);
    },

    // :: -> Table?
    getType() { return this.query.makePath(this.path).getParent().getType(); },

    // :: -> Service
    getService() { return this.query.service; }
  };
};


