const {Promise} = require('es6-promise');

const Options = require('../options');
const Page = require('../models/page');

const CACHES = {};
const ALREADY_DONE = Promise.resolve(true);

exports.getCache = function(query) {
  let name;
  const xml = query.toXML();
  const { root } = query.service;
  return CACHES[name = root + ':' + xml] != null ? CACHES[name] : (CACHES[name] = new ResultCache(query));
};

// TODO - make sure that the caches are informed of list change events.
exports.onListChange = function(listName) {
  for (let name in CACHES) {
    var needle;
    const cache = CACHES[name];
    if ((needle = listName, Array.from(listNamesFor(cache.query)).includes(needle))) {
      cache.dropRows(); // we cannot rely on this cache if one of its queries has changed.
    }
  }
  return false;
};

// An object that maintains a results cache for a given version of a query. Instances
// of this object should *only* be obtained with the `getCache` method, which
// guarantees that the results will be correct.
//
// note for testing: the required API of the query object is:
//   * has `clone` method that returns an object with a `tableRows(page)` method,
//   which when called returns a `Promise<[[TableCellResult]]>`
//
class ResultCache {
  static initClass() {
  
    this.prototype.offset = 0; // :: int
    this.prototype.rows = null;
     // []? - single contiguous cache of rows.
  }

  constructor(query) {
    this.query = query.clone(); // freeze this query, so it does not change.
  }

  toString() { if ((this.rows != null ? this.rows.length : undefined)) {
    return `ResultCache(${ this.offset } .. ${ this.offset + this.rows.length })`;
  } else {
    return "ResultCache(EMPTY)";
  } }

  // This is *the* primary external public API method. All others should be
  // considered private.
  //
  // :: start :: int, size :: int?  -> Promise<rows>
  fetchRows(start, size = null) {
    if (start == null) { start = 0; }
    const page = new Page(start, size);
    const updating = this.updateCache(page);
    return updating.then(() => this.getRows(page));
  }

  updateCache(page) {
    if (this.contains(page)) { return ALREADY_DONE; }

    // Return a promise to update the cache
    const p = this.getRequestPage(page);

    // @overlayTable() # FIXME - move overlay stuff back to table.
    // fetching.then @removeOverlay, @removeOverlay
    return this.query.tableRows({start: p.start, size: p.size})
                 .then(this.addRowsToCache(p));
  }

  contains(page) {
    const cache = this.rows;
    // We definitely don't have it if we don't have any results cached.
    if (!(cache != null ? cache.length : undefined)) { return false; }
    const end = this.offset + cache.length;
 
    // We need new data if the range of this request goes beyond
    // that of the cached values, or if all results are selected.
    return (!page.all()) && (page.start >= this.offset) && (page.end() <= end);
  }

  dropRows() {
    this.rows = null;
    return this.offset = 0;
  }

  // Transform a table page into a larger request page.
  getRequestPage(page) {
    let gap;
    const cache = this.rows;
    const factor = Options.get('TableResults.CacheFactor');
    const requestLimit = Options.get('TableResults.RequestLimit');
    const size = page.all() ? page.size : page.size * factor;

    // Can ignore the cache if it hasn't been set, just return the expanded page.
    if ((cache == null)) {
      return new Page(page.start, size);
    }

    const upperBound = this.offset + cache.length;

    // When paging backwards - extend page towards 0.
    const start = page.all() || (page.start >= this.offset) ?
      page.start
    :
      Math.max(0, page.start - size);

    const requestPage = new Page(start, size);

    // Don't permit gaps, so try to keep the cache contiguous.

    // We only care if the requestPage is entirely left or right of the current cache.
    if (requestPage.isBefore(this.offset)) {
      gap = requestPage.rightGap(this.offset);
      if ((gap + requestPage.size) > requestLimit) {
        this.dropRows(); // prefer to dump the cache rather than request this much
      } else {
        requestPage.size += gap;
      }
    } else if (requestPage.isAfter(upperBound)) {
      gap = requestPage.leftGap(upperBound);
      if ((gap + requestPage.size) > requestLimit) {
        this.dropRows(); // prefer to dump the cache rather than request this much
      } else {
        requestPage.size += gap;
        requestPage.start = upperBound;
      }
    }

    return requestPage;
  }

  // Update the cache with the retrieved results. If there is an overlap 
  // between the returned results and what is already held in cache, prefer the newer 
  // results.
  //
  // @param page The page these results were requested with.
  // @param rows The rows returned from the server.
  //
  addRowsToCache(page) { return rows => {
    let cache = this.rows;
    let { offset } = this;
    if (cache != null) { // may not exist if this is the first request, or we have dumped the cache.
      const upperBound = this.offset + cache.length;

      // Add rows we don't have to the front - TODO: use splice rather than slice!
      if (page.start < offset) {
        if (page.end() < offset) {
          throw new Error(`Cannot add ${ page } to ${ this } - non contiguous`);
        }
        if (page.all() || (page.end() > upperBound)) {
          cache = rows.slice(); // containment, rows replace cache.
        } else { // concat together
          cache = rows.concat(cache.slice(page.end() - offset));
        }
      } else if (page.start > upperBound) {
        throw new Error(`Cannot add ${ page } to ${ this } - non contiguous`);
      } else if (page.all() || (upperBound < page.end())) {
        // Add rows we don't have to the end
        cache = cache.slice(0, (page.start - offset)).concat(rows);
      } else {
        console.error(`Useless cache add - we already had these rows: ${ page }`);
      }

      offset = Math.min(offset, page.start);
    } else {
      cache = rows.slice();
      offset = page.start;
    }

    this.offset = offset;
    this.rows = cache;
    return true;
  }; }

  // Extract the given rows from the cache. When this method is called the
  // cache must have been populated by `updateCache`, so don't call it
  // directly.
  getRows({start, size}) {
    if (this.rows == null) { throw new Error('Cache has not been updated'); }
    const rows = this.rows.slice(); // copy the cached rows, so we don't truncate the cache.
    // Splice off the undesired sections.
    rows.splice(0, start - this.offset);
    if ((size != null) && (size > 0)) { rows.splice(size, rows.length); }
    return rows;
  }
}
ResultCache.initClass();

exports.ResultCache = ResultCache; // exported for testing.
