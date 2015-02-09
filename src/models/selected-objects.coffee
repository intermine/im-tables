CoreModel = require '../core-model'
Collection = require '../core/collection'

types = require '../core/type-assertions'

# This class defines our expectations for the data that 
# the selected objects collection contains.
class SelectionModel extends CoreModel

  defaults: ->
    'class': null
    'id': null

  validate: (attrs, opts) ->
    if 'class' of attrs
      return '"class" must not be null' unless attrs['class']?

    if 'id' of attrs
      return '"id" must not be null' unless attrs.id?

    return false

# A collection that monitors its contents and calculates some
# aggregate values based on them - specificially the common
# type of its contents.
module.exports = class SelectedObjects extends Collection

  model: SelectionModel

  constructor: (service) ->
    super()
    types.assertMatch types.Service, service, 'service'
    @state = new CoreModel commonType: null, typeName: null
    @listenTo @state, 'change:commonType', @onChangeType
    @listenTo @, 'add remove reset', @setType
    service.fetchModel().then (@schema) => @setType()

  onChangeType: ->
    return unless @schema? # wait until we have the data model.
    type = @state.get('commonType')
    return @state.set(typeName: null) unless type?
    path = @schema.makePath type
    path.getDisplayName().then (name) =>
      @state.set typeName: name
      @trigger 'change:typeName change'
    @trigger 'change:commonType change'

  setType: ->
    return unless @schema? # wait until we have the data model.

    commonType = if @size()
      commonType = @schema.findCommonType @map (o) -> o.get 'class'
    else
      null

    if commonType?
      @state.set commonType: commonType
    else
      @state.set
        commonType: null
        typeName: null

