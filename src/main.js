// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('underscore');

require('./shim');

const {Service: {connect}} = require('imjs');
const {Promise} = require('es6-promise');

const version = require('./version');
const Types = require('./core/type-assertions');
const Dashboard = require('./views/dashboard');
const Table = require('./views/table');
const Options = require('./options');
const Messages = require('./messages');
const Formatting = require('./formatting');
const simpleFormatter = require('./utils/simple-formatter');

// (Query, Obj -> V) -> (Elementable, {start, size}, QueryDef) -> Promise V
//   where Elementable = Element | String | Indexed<Element>
//         QueryDef = Query | {service :: Servicelike, query :: Querylike}
//         Servicelike = Service | {root :: String, token :: String?}
//         Querylike = Query | QueryJson
const load = function(create) { let loadView;
return loadView = function(elem, opts, queryDef) {
  if (Types.Query.test(queryDef)) {
    return new Promise(createView(create, elem, queryDef, opts));
  } else { // we have to lift the query def to a query.
    const {service, query} = queryDef;
    const conn = Types.Service.test(service) ? service : connect(service);
    return conn.query(query).then(_.partial(loadView, elem, opts));
  }
}; };

// Given a factory function and some arguments, create and render a view.
// (factry, Elementable, Query, Page) -> Promiser
var createView = function(create, elem, query, opts) { if (opts == null) { opts = {}; } return function(resolve) {
  // Find the element referred to - throw an error otherwise.
  const element = asElement(elem);
  // Pick white-listed properties off the page.
  const model = (typeof page !== 'undefined' && page !== null) ? (_.pick(opts, 'start', 'size')) : null;
  opts = _.extend((_.omit(opts, 'start', 'size')), {model, query});
  // Create the view
  const view = create(opts);

  // Set the view up correctly, making sure it has the right CSS classes.
  view.setElement(element);
  for (let c of Array.from((_.result(view, 'className')).split(' '))) { element.classList.add(c); }
  element.classList.add(Options.get('StylePrefix'));
  view.render();

  return resolve(view);
}; };

// Element | String | Indexed<Element> -> Element
var asElement = function(e) {
  if (e == null) { throw new Error('No target element provided'); }
  const ret = _.isString(e) ? document.querySelector(e) : (e[0] != null ? e[0] : e);
  if (ret == null) { throw new Error(`Target(${ e }) not found on page`); }
  return ret;
};

// Exported top-level API

// The version of this library, see: bin/inject-version.js
exports.version = version;

// Allow end users to configure text.
exports.setMessages = Messages.set.bind(Messages);

// Set global options (see src/options)
exports.configure = Options.set.bind(Options);

// :: (elem, page, query) -> Promise Table
exports.loadTable = load(Table.create);

// :: (elem, page, query) -> Promise Dashboard
exports.loadDash = load(opts => new Dashboard(opts));

// Allow 3rd parties to create new simple formatters
exports.createFormatter = simpleFormatter;

// re-export the public formatting API:
//   * registerFormatter
//   * disableFormatter
//   * enableFormatter
exports.formatting = _.omit(Formatting, 'getFormatter', 'shouldFormat', 'reset');

