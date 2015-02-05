Templates = require '../../templates'
CoreView = require '../../core-view'
CoreModel = require '../../core-model'
Options = require '../../options'
Collection = require '../../core/collection'
PathModel = require '../../models/path'
Messages = require '../../messages'

{ignore} = require '../../utils/events'

HIDDEN_FIELDS = ['class', 'objectId'] # We don't show these fields.

getLeaves = (o) ->
  leaves = []
  values = (leaf for name, leaf of o when name not in HIDDEN_FIELDS)
  for x in values
    if x.objectId
      leaves = leaves.concat(getLeaves(x))
    else
      leaves.push(x)
  leaves

# {NUM_SEPARATOR, NUM_CHUNK_SIZE, CellCutoff} = intermine.options

class SortedByName extends Collection

  comparator: 'displayName'

  idAttribute: 'path'

  initialize: ->
    @listenTo @, 'change:displayName', @sort

class ItemDetails extends CoreView

  ITEMS = Templates.template 'cell-preview-items'

  REFERENCE = Templates.template 'cell-preview-reference'

  ATTR = Templates.template 'cell-preview-attribute'

  tagName: 'table'

  className: 'im-item-details table table-condensed table-bordered'

  collectionEvents: -> add: @addDetail

  template: ITEMS

  render: ->
    @el.innerHTML = @template()
    @collection.each (details) => @addDetail details
    @trigger 'rendered', @rendered = true

  addDetail: (details) ->
    f = if ('ATTR' is details.get 'fieldType') then ATTR else REFERENCE
    @$el.append f details.toJSON()

  events: ->
    'click .im-too-long': @revealLongField

  revealLongField: (e) ->
    ignore e
    $tooLong = @$ '.im-too-long'
    $overSpill = @$ '.im-overspill'
    $tooLong.remove()
    $overSpill.slideDown 250

class ReferenceCounts extends CoreView

  RELATION = Templates.template 'cell-preview-reference-relation'

  className: 'im-related-counts'

  tagName: 'ul'

  collectionEvents: -> add: @reRender

  postRender: ->
    @collection.each (details) => @$el.append RELATION details.toJSON()
    @trigger 'ready'

# the model for the preview needs a type and an id.
class PreviewModel extends CoreModel

  defaults: ->
    type: null
    id: null
    error: null
    phase: 'INIT'

module.exports = class Preview extends CoreView

  className: 'im-cell-preview-inner'

  THROBBER = Templates.active_progress_bar

  ERROR = Templates.template 'cell-preview-error'

  parameters: ['service', 'model']

  initialize: ->
    super
    @fieldDetails = new SortedByName
    @referenceFields = new SortedByName

    @service.fetchModel().then (@schema) => @reRender()

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

  fetchData: ->
    type = @model.get 'type'
    types = type.split ',' # could be a dynamic object.

    gettingDetails = (@getDetails t for t in type.split ',')
    gettingCounts = @getRelationCounts()

    gettingDetails.concat gettingCounts
                  .reduce (p1, p2) -> p1.then -> p2

  getDetails: (type) ->
    id = @model.get('id')
    @service.findById(type, id).then @handleItem

  # Reads values from the returned items and adds details objects to the 
  # fieldDetails and referenceFields collections, avoiding duplicates.
  # # FIXME: continue from here.
  handleItem: (item) =>
    field = null
    cuttoff = Options.get 'CellCutoff'

    # Attribute fields get processed first.
    for field, v of item when v and (field not in HIDDEN_FIELDS) and not v.objectId
      if not @fieldDetails.findWhere({field}) then do (field, v) =>
        valueString = String value
        tooLong = value.length > cuttoff
        snipPoint = value.indexOf ' ', cuttoff * 0.9 # Try and break on whitespace
        snipPoint = cuttoff if snipPoint is -1 # too bad, break here then.
        value = if tooLong then value.substring(0, snipPoint) else value
        valueOverspill = (v + '').substring(snipPoint)
        details = {fieldType: 'ATTR', field, value, tooLong, valueOverspill}
        @formatName(field).then (name) =>
          details.name = name
          @fieldDetails.add details
      
    # Reference fields.
    for field, value of item when value and value.objectId
      if not @fieldDetails.findWhere({field}) then do (field, value) =>
        values = getLeaves(value)
        details = {fieldType: 'REF', field, values}
        @formatName(field).then (name) =>
          details.name = name
          @fieldDetails.add details

    this

  concat = (xs, ys) -> xs.concat ys

  getRelationCounts: ->
    types = @model.get 'type'
    root = @service.root
    opts = Options.get ['Preview', 'Count', root]
    return [] unless opts?

    countSets = for type in types.split(',')
      for settings in (opts[type] ? [])
        @getRelationCount settings, type

    # Flatten the sets of promises into a single collection.
    countSets.reduce concat, []

  getRelationCount: (settings, type) ->
    id = @model.get 'id'

    if _.isObject settings
      {query, label} = settings
      counter = query id # query is a function from id -> query # TODO!!!
    else
      label = settings
      counter = select: settings + '.id', from: type, where: {id}

    @service.count(counter).then (c) => @referenceFields.add name: label, count: c

  fetching: null

  template: ({state, error}) -> switch state
    when 'FETCHING' then THROBBER
    when 'ERROR' then ERROR error
    else null

  preRender: -> # Fetch data, but no more than once.
    m = @model
    @fetching ?= @fetchData()
    @fetching.then (-> m.set phase: 'SUCCESS'), ((e) -> m.set phase: 'ERROR', error: e)

  postRender: -> if 'SUCCESS' is @model.get('phase')

    itemDetailsTable = new ItemDetails collection: @fieldDetails
    @renderChild 'details', itemDetailsTable

    countsTitle = new CountsTitle collection: @referenceFields
    @renderChild 'counttitle', countsTitle

    referenceCounts = new ReferenceCounts collection: @referenceFields
    @renderChild 'counts', referenceCounts

class CountsTitle extends CoreView

  tagName: 'h4'

  collectionEvents: -> 'add remove reset': @setVisibility

  setVisibility: -> @$el.toggleClass 'im-hidden', @collection.isEmpty()

  template: -> _.escape Messages.getText 'preview.RelatedItemsHeading'

  postRender: -> @setVisibility()
