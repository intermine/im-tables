_ = require 'underscore'

{Query: {LIST_OPS, LOOP_OPS, TERNARY_OPS, RANGE_OPS, NULL_OPS}} = require 'imjs'

PathModel = require './path'

constraintType = (opts) ->
  if opts.path.isAttribute()
    return 'MULTI_VALUE' if opts.values
    return 'ATTR_VALUE'
  else
    return 'TYPE' if opts.type
    return 'IDS' if opts.ids
    return 'RANGE' if opts.values and (opts.op in RANGE_OPS)
    return 'LOOKUP' if (opts.op in TERNARY_OPS)
    return 'LIST' if (opts.op in LIST_OPS)
    return 'LOOP' if (opts.op in LOOP_OPS)
    return opts.op if (opts.op in NULL_OPS)
  throw new Error("Cannot determine constraint type: #{ opts.path } #{ opts.op }")

# A rather ugly but convenient reutilisation of PathModel
# to provide the displayName etc conveniences in ConstraintModel.
# The two difficulties are making sure the id is unique (as
# constraints can have the same path) and avoiding conflicts with type.
#
# Future work might want to improve this.
module.exports = class ConstraintModel extends PathModel

  defaults: -> _.extend super,
    value: null
    values: []
    ids: []
    extraValue: null
    code: null
    CONSTRAINT_TYPE: 'ATTR_VALUE'

  constructor: (opts) ->
    super opts.path
    type = opts.type
    @unset 'id'
    @unset 'type'
    @set (_.omit opts, 'path', 'type')
    if type?
      @set type: type.toString()
      type.getDisplayName().then (name) => @set typeName: name

    @set CONSTRAINT_TYPE: constraintType opts
