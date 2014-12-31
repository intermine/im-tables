_ = require 'underscore'

# Mixin method that runs a query, defined by @query and the values of @model
exports.runQuery = (overrides = {}) ->
  @query.service.post 'query/results', @getExportParameters overrides

exports.getExportURI = (overrides) ->
  @query.getExportURI @model.get('format').id, @getExportParameters overrides

exports.getExportParameters = (overrides = {}) ->
  data = @model.pick 'start', 'size', 'format'
  data.format = data.format.id
  data.query = @query.toXML()
  if @model.get 'headers'
    data.columnheaders = @model.get 'headerType'
  # TODO - this is hacky - the model should reflect the request
  if (data.format is 'json') and ('rows' isnt @model.get 'jsonFormat')
    data.format += @model.get 'jsonFormat'
  _.extend data, overrides
