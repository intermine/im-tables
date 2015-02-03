{shouldFormat} = require '../formatting'

isIDPath = (p) -> p.isAttribute() and p.end.name is 'id'

# Return whether a column is replaced by another.
# :: ({string: Column}) -> (Column) -> bool
module.exports = getReplacedTest = (formatReplacements, allReplacements) -> (col) ->
  throw new Error 'no column' unless col?
  p = col.path # we perform lookups by path.
  return false unless (shouldFormat p) or (p of allReplacements)
  # Find the path that replaces this one by its name, or by its parent's name, if this
  # is the id path.
  replacer = formatReplacements[p]
  replacer ?= formatReplacements[p.getParent()] if isIDPath p
  # Finally check that there is in fact a valid replacer that does formatting, and
  # that it isn't in fact this same path.
  replacer and replacer.formatter? and (col isnt replacer)

