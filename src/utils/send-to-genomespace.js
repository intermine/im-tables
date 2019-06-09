_ = require 'underscore'
{Promise} = require 'es6-promise'

Options = require '../options'

{fromPairs} = require './query-string'

getGenomeSpaceUrl = (uri, fileName) ->
  GenomeSpace = Options.get 'Destination.GenomeSpace'
  pairs = [['uploadUrl', uri], ['fileName', fileName]]
  qs = fromPairs pairs
  "#{ GenomeSpace.Upload }?#{ qs }"

save = (uri, fileName) -> new Promise (resolve, reject) ->
  # Open the GS pop-up interface.
  win = window.open getGenomeSpaceUrl uri, fileName

  # Yes, technically this is a pointless wrapper function, but
  # it makes the API clearer.
  win.setCallbackOnGSUploadComplete = (savePath) -> resolve savePath
  # We don't get sensible errors back, so just construct one.
  win.setCallbackOnGSUploadError = (savePath) ->
    console.log 'GSERR', arguments
    reject new Error "Could not save to #{ savePath }"
  win.addEventListener 'unload', -> reject new Error 'Upload cancelled'

  win.focus()

module.exports = save
