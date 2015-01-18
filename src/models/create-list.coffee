_ = require 'underscore'
CoreModel = require '../core-model'
CoreCollection = require '../core/collection'

ON_COMMA = /,\s*/

trim = (s) -> s.replace(/(^\s+|\s+$)/g, '')

module.exports = class CreateListModel extends CoreModel

  defaults: ->
    name: null
    description: null

  initialize: ->
    @tags = new CoreCollection
    if @has 'tags'
      @tags.reset( {id: tag} for tag in @get 'tags' )
    @listenTo @tags, 'remove', (t) =>
      @trigger 'remove:tag', t
      @trigger 'change'
    @listenTo @tags, 'add', (t) =>
      @trigger 'add:tag', t
      @trigger 'change'

  toJSON: -> _.extend super, tags: @tags.map (t) -> t.get 'id'

  addTag: ->
    tags = @get 'nextTag'
    throw new Error('No tag to add') unless tags?
    @unset 'nextTag'
    for tag in trim(tags).split ON_COMMA 
      @tags.add {id: tag}

  destroy: ->
    @tags.close()
    super


