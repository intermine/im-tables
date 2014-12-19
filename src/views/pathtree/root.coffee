_ = require 'underscore'

Icons = require '../../icons'

Attribute = require './attribute'

module.exports = class RootClass extends Attribute

  className: 'im-rootclass'

  initialize: (opts) ->
    {cd, @openNodes} = opts
    opts.trail = []
    opts.path = opts.query.getPathInfo cd.name

    super opts

  getData: -> _.extend super(), icon: Icons.icon('RootClass')

  handleClick: (e) ->
    e?.preventDefault()
    e?.stopPropagation()
    if @$(e.target).is('i') or (not @model.get('canSelectReferences'))
      if @openNodes.size()
        @openNodes.reset []
      else
        {collections, references} = @path.getType()
        paths = (@path.append r.name for r in _.values(references).concat(_.values collections))
        @openNodes.reset paths
    else
      super(e)
