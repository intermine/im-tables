_ = require 'underscore'
fs = require 'fs'
{Promise} = require 'es6-promise'

Messages = require '../messages'
View = require '../core-view'

toNamedPath = require '../utils/to-named-path'
helpers = require '../templates/helpers'

html = fs.readFileSync __dirname + '/../templates/type-value-controls.html', 'utf8'

asOption = ({path, name}) -> value: path, text: name

module.exports = class TypeValueControls extends View

  initialize: ({@query}) ->
    super
    # Declare rendering dependency on messages and icons.
    @listenTo Messages, 'change', @reRender
    @setSubclasses()

  getData: ->
    type = @model.get 'type'
    data =
      select: helpers.select
      messages: Messages
      options: (asOption sc for sc in (@model.get('subclasses') ? []))
      isSelected: (opt) -> type is opt.value

  events: ->
    'change .im-value-type': 'setType'

  setType: -> @model.set type: @('.im-value-type').val()

  template: _.template html

  setSubclasses: -> unless @model.has('subclasses')
    @getPossibleTypes().then (subclasses) => @model.set {subclasses}

  # Get the list of sub-types that this constraint could be set to.
  getPossibleTypes: -> @__possible_types ?= do =>
    # get a promise for possible paths, cached so we don't have to keep going back to the model.
    {path, type} = @model.toJSON()
    subclasses = @query.getSubclasses()
    schema = @query.model
    delete subclasses[@path] # no point unless we unconstrain it, but we may need other type-cons
    baseType = schema.getPathInfo(@path, subclasses).getType()
    paths = (schema.makePath t for t in schema.getSubclassesOf baseType)
    Promise.all paths.map toNamedPath
