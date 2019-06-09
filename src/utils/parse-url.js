_ = require 'underscore'

pairsToParams = (pairs) ->
  _.object(p.split('=').map(decodeURIComponent) for p in pairs)

module.exports = (url) ->
  [URL, qs] = url.split '?'
  pairs = qs.split '&'
  params = pairsToParams pairs
  {URL, params}

