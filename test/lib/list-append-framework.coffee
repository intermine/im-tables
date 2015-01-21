$ = require 'jquery'
{Promise} = require 'es6-promise'

tempListAttrs =
  name: 'APPEND TO ME'
  description: 'a temporary list to append to'
  tags: ['temp', 'test', 'deleteme']

{authenticatedConnection} = require './connect-to-service.coffee'
renderQueries = require './render-queries.coffee'
renderQueryWithCounter = require './render-query-with-counter-and-displays.coffee'

fail = console.error.bind(console)

tearDown = (quiet = false) ->
  c = authenticatedConnection
  getList = c.fetchList tempListAttrs.name
  getList.then (l) -> l.del()
         .then -> console.log 'cleaned up successfully'
         .then null, (e) -> console.error 'Failed to clean up!!', e unless quiet

exports.setup = setup = -> new Promise (resolve, reject) ->
  c = authenticatedConnection
  getQuery = c.query select: ['Employee.id'], where: {'department.name': 'Sales'}
  makeList = (q) -> q.saveAsList tempListAttrs
  tryToMakeList = -> getQuery.then(makeList).then resolve, reject
  tearDown(quiet = true).then tryToMakeList, tryToMakeList

exports.done = done = (res) ->
  return console.log('dialogue dismissed - no list created') if res is 'dismiss'
  list = res
  console.log 'SUCCESS - appended to', list
  tearDown()

showDialogue = (dialogue) -> dialogue.show().then done, fail
listToDefault = ['model', 'possibleLists', 'state']

exports.runWithQuery = (queries, create, listenTo = listToDefault, after = showDialogue) ->
  renderQuery = renderQueryWithCounter create, after, listenTo
  $ -> setup().then (-> renderQueries queries, renderQuery, authed = true), fail

