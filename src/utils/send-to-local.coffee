_ = require 'underscore'
{Promise} = require 'es6-promise'

# Utils that promise to return some metadata.
existingWindowWithPost = require './existing-window-with-post'

module.exports = send = (url, filename, onProgress, exportModel) ->

  endpoint = 'query/results'
  format = @model.format
  # Custom formats have custom endpoints.
  endpoint += "/#{ format.id }" if format.needs?.length

  parameters = exportModel.getExportParameters();
  parameters.token = @query.service.token

  existingWindowWithPost @query.service.root + endpoint, null, parameters
  Promise.resolve null
