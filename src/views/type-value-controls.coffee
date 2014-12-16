_ = require 'underscore'
fs = require 'fs'
{Promise} = require 'es6-promise'

Messages = require '../messages'
View = require '../core-view'

Messages.set
  'typeconstraints.BadType': """
    <%- type %> is not a legal value for this constraint. Choose another from the list.
  """
  'typeconstraints.OneClass': """
    <%- name %> is the only legal value this constraint can have. You can always remove it though.
  """

toNamedPath = require '../utils/to-named-path'
helpers = require '../templates/helpers'

html = fs.readFileSync __dirname + '/../templates/type-value-controls.html', 'utf8'

asOption = ({path, name}) -> value: path, text: name

module.exports = class TypeValueControls extends View

  initialize: ({@query}) ->
    super
    @listenTo Messages, 'change', @reRender
    @listenTo @state, 'change:subclasses', @reRender
    @setSubclasses()

  getData: ->
    type = @model.get 'type'
    data =
      select: helpers.select
      messages: Messages
      subclasses: (asOption sc for sc in (@state.get('subclasses') ? []))
      isSelected: (opt) -> type is opt.value

  events: ->
    'change .im-value-type': 'setType'

  setType: -> @model.set type: @$('.im-value-type').val()

  template: _.template html

  setSubclasses: -> unless @model.has('subclasses')
    @getPossibleTypes().then (subclasses) =>
      if subclasses.length is 1
        msg = Messages.getText('typeconstraints.OneClass', subclasses[0])
        @model.set error: {message: msg, level: 'warning'}
      @state.set {subclasses}

  # Get the list of sub-types that this constraint could be set to.
  getPossibleTypes: ->
    {path, type} = @model.toJSON()
    subclasses   = @query.getSubclasses()
    schema       = @query.model

    delete subclasses[path] # no point unless we unconstrain it, but we may need other type-cons
    baseType = schema.getPathInfo(path.toString(), subclasses).getType()
    subtypes = (t for t in schema.getSubclassesOf baseType when t isnt baseType.name)
    paths = (schema.makePath t for t in subtypes)
    promises = paths.map toNamedPath
    unless type in subtypes # Add it there if it isn't one of them, with a warning.
      @model.set error: new Error Messages.getText 'typeconstraints.BadType', @model.toJSON()
      promises.push Promise.resolve path: type, name: @model.get('typeName')
    Promise.all promises
