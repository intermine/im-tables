_ = require 'underscore'
{Promise} = require 'es6-promise'

Templates = require '../templates'
CoreView = require '../core-view'
CoreModel = require '../core-model'
Options = require '../options'
Collection = require '../core/collection'
PathModel = require '../models/path'
types = require '../core/type-assertions'
getLeaves = require '../utils/get-leaves'

ItemDetails = require './item-preview/details'
ReferenceCounts = require './item-preview/reference-counts'
CountsTitle = require './item-preview/counts-title'

# {NUM_SEPARATOR, NUM_CHUNK_SIZE, CellCutoff} = intermine.options

class DetailsModel extends PathModel

  constructor: (opts) ->
    super opts.path
    @set _.omit opts, 'path'

class AttrDetailsModel extends DetailsModel

  defaults: -> _.extend super,
    fieldType: 'ATTR'
    valueOverspill: null
    tooLong: false
    value: null

class RefDetailsModel extends DetailsModel

  defaults: -> _.extend super,
    fieldType: 'REF'
    values: []

class SortedByName extends Collection

  comparator: 'displayName'

  initialize: ->
    @listenTo @, 'change:displayName', @sort

# the model for the preview needs a type and an id.
class PreviewModel extends CoreModel

  defaults: ->
    type: null
    id: null
    error: null
    phase: 'FETCHING' # one of FETCHING, SUCCESS, ERROR

THROBBER = Templates.active_progress_bar

ERROR = Templates.template 'cell-preview-error'

HIDDEN_FIELDS = ['class', 'objectId'] # We don't show these fields.

# fn version of Array.concat
concat = (xs, ys) -> xs.concat ys
# Accept non-null attrs.
acceptAttr = -> (f, v) ->
  v? and (not v.objectId) and (f not in HIDDEN_FIELDS)
acceptRef = -> (f, v) -> value?.objectId

module.exports = class Preview extends CoreView

  Model: PreviewModel

  className: 'im-cell-preview-inner'

  parameters: ['service']

  parameterTypes:
    service: types.Service

  initialize: ->
    super
    @fieldDetails = new SortedByName
    @referenceFields = new SortedByName

  modelEvents: ->
    'change:phase': @reRender
    'change:error': @reRender

  remove: ->
    @removeAllChildren()
    @fieldDetails.close()
    @referenceFields.close()
    delete @fieldDetails
    delete @referenceFields
    super

  fetching: null

  template: ({state, error}) -> switch state
    when 'FETCHING' then THROBBER
    when 'ERROR' then ERROR error
    else null

  preRender: -> # Fetch data, but no more than once.
    m = @model
    @fetching ?= @fetchData()
    @fetching.then (-> m.set phase: 'SUCCESS'), (e) ->
      m.set phase: 'ERROR', error: e

  postRender: -> if 'SUCCESS' is @model.get('phase')
    for t in @model.get('type').split(',')
      @$el.addClass t

    itemDetailsTable = new ItemDetails collection: @fieldDetails
    @renderChild 'details', itemDetailsTable

    countsTitle = new CountsTitle collection: @referenceFields
    @renderChild 'counttitle', countsTitle

    referenceCounts = new ReferenceCounts collection: @referenceFields
    @renderChild 'counts', referenceCounts

    @$el.append Templates.clear

  # Fetching requires the InterMine data model, which we name
  # schema here for reasons of sanity (namely collision with the
  # Backbone model located at @model)
  fetchData: -> @service.fetchModel().then (@schema) =>
    type = @model.get 'type'
    types = type.split ',' # could be a dynamic object.

    gettingDetails = @getAllDetails types
    gettingCounts = @getRelationCounts types

    Promise.all gettingDetails.concat gettingCounts

  getAllDetails: (types) ->
    (@getDetails t for t in types)

  getDetails: (type) ->
    id = @model.get('id')
    @service.findById(type, id).then @handleItem

  # Reads values from the returned items and adds details objects to the 
  # fieldDetails and referenceFields collections, avoiding duplicates.
  handleItem: (item) =>
    coll = @fieldDetails
    testAttr = acceptAttr coll
    testRef = acceptRef coll

    for field, value of item when (testAttr field, value)
      @handleAttribute item, field, value
      
    for field, value of item when (testRef field, value)
      @handleSubObj item, field, value

    return null

  # Turns references returned from into name: values pairs
  handleSubObj: (item, field, value) ->
    values = getLeaves value, HIDDEN_FIELDS
    path = @schema.makePath "#{ item['class'] }.#{ field }"
    details = {path, field, values}

    @fieldDetails.add new RefDetailsModel details

  handleAttribute: (item, field, rawValue) ->
    cuttoff = Options.get 'CellCutoff'
    path = @schema.makePath "#{ item['class'] }.#{ field }"
    valueString = String rawValue
    tooLong = valueString.length > cuttoff
    details = {tooLong, path, field, value: valueString}

    if tooLong # Try and break on whitespace
      snipPoint = valueString.indexOf ' ', cuttoff * 0.9
      snipPoint = cuttoff if snipPoint is -1 # too bad, break here then.
      details.valueOverspill = valueString.substring(snipPoint)
      details.value = valueString.substring 0, snipPoint

    @fieldDetails.add new AttrDetailsModel details

  getRelationCounts: (types) ->
    root = @service.root
    opts = (Options.get ['Preview', 'Count', root]) ? {}

    countSets = for type in types
      cld = @schema.classes[type]
      for settings in (opts[type] ? (c for c of cld.collections))
        @getRelationCount settings, type

    # Flatten the sets of promises into a single collection.
    countSets.reduce concat, []

  getRelationCount: (settings, type) ->
    id = @model.get 'id'

    if _.isObject settings
      {query, label} = settings
      counter = query id # query is a function from id -> query
      details = (c) -> parts: [label], id: label, displayName: label, count: c
    else
      path = @schema.makePath "#{ type }.#{ settings }"
      counter = select: [settings + '.id'], from: type, where: {id}
      details = (c) -> new DetailsModel {path, count: c}

    @service.count counter
            .then details
            .then (d) => @referenceFields.add d
