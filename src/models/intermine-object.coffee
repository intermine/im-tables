CoreModel = require '../core-model'
    
# The data fields are separated from things like selectable, etc
# by using colons in their field names, which are illegal data field name characters.
module.exports = class IMObject extends CoreModel

  constructor: (@query, base) ->
    super()
    @set 'service:base': base
    # TODO - can we avoid using the query as an event bus here?
    @listenTo @query, 'selection:cleared', @makeSelectable
    @listenTo @query, 'common:type:selected', @typeSelected
    @listenTo @, 'click', @onClick
    @listenTo @, 'change:is:selected', @onChangeSelected

  onChangeSelected: ->
    @query.trigger "imo:selected", @get("obj:type"), @get("id"), @get('is:selected')

  onClick: -> @query.trigger 'imo:click', @get('obj:type'), @get('id'), @toJSON()

  makeSelectable: -> @set 'is:selectable': true

  isa: (type) -> !! @model.findSharedAncestor type, @get 'obj:type'

  typeSelected: (type) -> @set 'is:selectable': (not type) or (@isa type)

  defaults: ->
    'is:selected': false
    'is:selectable': true
    'is:selecting': false

  selectionState: ->
    selected: @get 'is:selected'
    selecting: @get 'is:selecting'
    selectable: @get 'is:selectable'

  merge: (obj, field) ->
    @set field, obj.value
    @set 'obj:type': obj.class, 'service:url': obj.url

