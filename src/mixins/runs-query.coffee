_ = require 'underscore'

CACHE = {}

# Mixin method that runs a query, defined by @query and the values of @model
exports.runQuery = (overrides = {}) ->
  params = @getExportParameters overrides
  key = "results:#{ @query.service.root }:#{ JSON.stringify params }"
  endpoint = 'query/results'
  format = @model.get('format')
  # Custom formats have custom endpoints.
  endpoint += "/#{ format.id }" if format.needs?.length
  CACHE[key] ?= @query.service.post endpoint, params

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
  data = @model.pick 'start', 'size', 'format', 'filename'
  data.format = data.format.id
  data.query = @getExportQuery().toXML()
  if @model.get 'compress'
    data.compress = @model.get 'compression'
  if @model.get 'headers'
    data.columnheaders = @model.get 'headerType'
  # TODO - this is hacky - the model should reflect the request
  if (data.format is 'json') and ('rows' isnt @model.get 'jsonFormat')
    data.format += @model.get 'jsonFormat'
  if (data.format is 'fasta') and (@model.get('fastaExtension'))
    data.extension = @model.get('fastaExtension')
  if (data.format is 'fasta') or (data.format is 'gff3')
    data.view = @model.get 'columns'
  _.extend data, overrides
