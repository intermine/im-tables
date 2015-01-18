_ = require 'underscore'
CoreModel = require '../core-model'
CoreCollection = require '../core/collection'

module.exports = class CreateListModel extends CoreModel

  defaults: ->
    listName: null
    listDesc: null

  initialize: ->
    @tags = new CoreCollection
    if @has 'tags'
      @tags.reset( {id: tag} for tag in @get 'tags' )
    @listenTo @tags, 'destroy', (t) => @tags.remove t

  toJSON: -> _.extend super, tags: @tags.map (t) -> t.get 'id'

  addTag: ->
    tag = @get 'nextTag'
    throw new Error('No tag to add') unless tag?
    @tags.add {id: tag}
    @unset 'nextTag'
    @trigger 'add:tag', @tags.get tag

  destroy: ->
    @tags.close()
    super


