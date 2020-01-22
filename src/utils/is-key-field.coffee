# Determine whether a path represents a key field, based on the
# class key definitions.
# :: {string: [string]} -> PathInfo -> bool
module.exports = isKeyField = (classKeys) -> (path) ->
  return false unless path.isAttribute()
  type      = path.getParent().getType().name
  fieldName = path.end.name
  keys      = classKeys?[type] ? []
  ("#{type}.#{fieldName}" in keys)

