_ = require 'underscore'

module.exports = (url) ->
  [URL, qs] = url.split '?'
  pairs = qs.split '&'
  {URL, params: _.object(p.split('=').map(unescape) for p in pairs)}

