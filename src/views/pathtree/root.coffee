_ = require 'underscore'

Icons = require '../../icons'

Attribute = require './attribute'

module.exports = class RootClass extends Attribute

  className: 'im-rootclass'

  initialize: (opts) ->
    {cd} = opts
    opts.trail = []
    opts.path = opts.query.getPathInfo cd.name

    super opts

  getData: -> _.extend super(), icon: Icons.icon('RootClass')
