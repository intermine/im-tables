renderQuery = require './render-query'
{connection, authenticatedConnection} = require './connect-to-service.coffee'

module.exports = (queries, f, authed = false) ->
  c = if authed then authenticatedConnection else connection
  container = document.querySelector("#demo")
  queries.forEach (q) -> renderQuery f, c, q, container
