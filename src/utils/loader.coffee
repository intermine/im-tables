options = require '../../options'
{utils} = require 'imjs'
$ = require 'jquery'

loader = (server) -> (resource) ->
  if /\.css$/.test resource
    link = $('<link type="text/css" rel="stylesheet">')
    link.appendTo('head').attr href: server + resource
    return utils.success()
  else
    fetch = $.ajax
      url: server + resource
      cache: true
      dataType: 'script'
    # script loaded, but possibly not executed: hang off a bit
    {promise, resolve} = utils.defer()
    fetch.then -> _.delay resolve, 50, true
    return promise

exports.load = (ident) ->
  {server, resources} = options.CDN
  conf = resources[ident]
  load = loader server
  if not conf
    utils.error "No resource is configured for #{ ident }"
  else if _.isArray(conf)
    utils.parallel conf.map load
  else
    load conf

