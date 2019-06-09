$ = require 'jquery'
{Promise} = require 'es6-promise'

Options = require '../options'
loadResource = require './load-resource'

loadDropbox = -> loadResource 'Destination.Dropbox.Library', 'Dropbox'

module.exports = (url, filename, onProgress) -> loadDropbox().then (Dropbox) ->
  new Promise (resolve, reject) ->
    Dropbox.appKey = Options.get 'auth.dropbox'
    Dropbox.save
      files: [ {url, filename} ]
      success:  resolve
      progress: onProgress
      cancel:   reject
      error:    reject
