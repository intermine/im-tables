Options = require '../options'
{Promise} = require 'es6-promise'

instances = {}

getInstance = (service) ->
  instances[service.root] ?= new Branding service

module.exports = (service) -> getInstance(service).getBranding()

class Branding

  constructor: (service) ->
    @key = service.root.replace /\./g, '_'
    @promise = service.get 'branding'
                      .then (info) => Options.set ['brand', @key], info.properties

  # Returns a promise that never fails, but may be resolved with null.
  # The purpose of this is to ensure that we only read the properties after we have attempted
  # to set them at least once.
  getBranding: -> new Promise (resolve) =>
    @promise.then (=> resolve Options.get ['brand', @key]), (-> resolve null)
