_ = require 'underscore'

CACHE = {}

# Mixin method that runs a query, defined by @query and the values of @model
exports.runQuery = (overrides = {}) ->
  params = @getExportParameters overrides
  key = "results:#{ @query.service.root }:#{ JSON.stringify params }"
  CACHE[key] ?= @query.service.post 'query/results', params

exports.getEstimatedSize = ->
  q = @getExportQuery()
  key = "count:#{ q.service.root }:#{ q.toXML() }"
  CACHE[key] ?= q.count()

exports.getExportQuery = ->
  toRun = @query.clone()
  columns = @model.get 'columns'
  if columns?.length
    toRun.select columns
  return toRun

exports.getExportURI = (overrides) ->
  @getExportQuery().getExportURI @model.get('format').id, @getExportParameters overrides

exports.getFileName = -> "#{ @getBaseName() }.#{ @getFileExtension() }"

exports.getBaseName = -> @model.get 'filename'

exports.getFileExtension = -> @model.get('format').ext

exports.getExportParameters = (overrides = {}) ->
  data = @model.pick 'start', 'size', 'format'
  data.filename = @getFileName()
  data.format = data.format.id
  data.query = @getExportQuery().toXML()
  if @model.get 'compress'
    data.compress = @model.get 'compression'
  if @model.get 'headers'
    data.columnheaders = @model.get 'headerType'
  # TODO - this is hacky - the model should reflect the request
  if (data.format is 'json') and ('rows' isnt @model.get 'jsonFormat')
    data.format += @model.get 'jsonFormat'
  _.extend data, overrides
