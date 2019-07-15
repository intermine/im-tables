let ColumnHeaders;
const Collection = require('../core/collection');
const HeaderModel = require('./header');

const buildHeaders = require('../utils/build-headers');

module.exports = (ColumnHeaders = (function() {
  ColumnHeaders = class ColumnHeaders extends Collection {
    static initClass() {
  
      this.prototype.model = HeaderModel;
  
      this.prototype.comparator = 'index';
    }

    initialize() {
      super.initialize(...arguments);
      return this.listenTo(this, 'change:index', this.sort);
    }

    // (Query, Collection) -> Promise
    setHeaders(query, banList) {
      const building = buildHeaders(query, banList);
      return building.then(hs => this.set(Array.from(hs).map((h) => new HeaderModel(h, query))));
    }
  };
  ColumnHeaders.initClass();
  return ColumnHeaders;
})());

