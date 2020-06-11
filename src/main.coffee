_ = require 'underscore'

require './shim'

{Service: {connect}} = require 'imjs'
{Promise} = require 'es6-promise'

version = require './version'
Types = require './core/type-assertions'
Dashboard = require './views/dashboard'
Table = require './views/table'
Options = require './options'
Messages = require './messages'
Formatting = require './formatting'
simpleFormatter = require './utils/simple-formatter'

# (Query, Obj -> V) -> (Elementable, {start, size}, QueryDef) -> Promise V
#   where Elementable = Element | String | Indexed<Element>
#         QueryDef = Query | {service :: Servicelike, query :: Querylike}
#         Servicelike = Service | {root :: String, token :: String?}
#         Querylike = Query | QueryJson
load = (create) -> loadView = (elem, opts, queryDef) ->
  if Types.Query.test queryDef
    new Promise createView create, elem, queryDef, opts
  else # we have to lift the query def to a query.
    {service, query} = queryDef
    conn = if Types.Service.test(service) then service else connect(service)
    conn.query(query).then _.partial loadView, elem, opts

# Given a factory function and some arguments, create and render a view.
# (factry, Elementable, Query, Page) -> Promiser
createView = (create, elem, query, opts = {}) -> (resolve) ->
  # Find the element referred to - throw an error otherwise.
  element = asElement elem
  # Pick white-listed properties off the page.
  model = if page? then (_.pick opts, 'start', 'size') else null
  opts = _.extend (_.omit opts, 'start', 'size'), model: model, query: query
  # Create the view
  view = create opts

  # Set the view up correctly, making sure it has the right CSS classes.
  view.setElement element
  (element.classList.add c for c in (_.result view, 'className').split(' '))
  element.classList.add Options.get 'StylePrefix'
  view.render()

  resolve view

# Element | String | Indexed<Element> -> Element
asElement = (e) ->
  throw new Error 'No target element provided' unless e?
  ret = if _.isString e then document.querySelector e else (e[0] ? e)
  throw new Error "Target(#{ e }) not found on page" unless ret?
  return ret

# Exported top-level API

# The version of this library, see: bin/inject-version.js
exports.version = version

# Allow end users to configure text.
exports.setMessages = Messages.set.bind(Messages)

# Set global options (see src/options)
exports.configure = Options.set.bind(Options)

# :: (elem, page, query) -> Promise Table
exports.loadTable = load Table.create

# Allow 3rd parties to create a table and externally manage the view rendering
exports.createTable = Table.create

# :: (elem, page, query) -> Promise Dashboard
exports.loadDash = load (opts) -> new Dashboard opts

# Allow 3rd parties to create new simple formatters
exports.createFormatter = simpleFormatter

# re-export the public formatting API:
#   * registerFormatter
#   * disableFormatter
#   * enableFormatter
exports.formatting = _.omit Formatting, 'getFormatter', 'shouldFormat', 'reset'

