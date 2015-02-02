Options = require '../options'

# This module provides logic for finding formatters registered for specific
# paths.  The semantics are that formatters are functions that are used to
# format a cell, and these are registered for one or more fields of an object.
# e.g: A formatter may handle ChromosomeLocation objects, but only handle the
# .start and .end fields, leaving .strand alone. In this case then the format
# set should have an entry at 'ChromosomeLocation' for the formatter, and one
# at 'ChromosomeLocation.start' and 'ChromosomeLocation.end' each with the
# value `true`, indicating that the formatter is to be looked up by class name.
# If on the other hand the formatter is meant to handle all paths, then a
# short-cut of 'ChromosomeLocation.*' can be used, which will match against all
# paths. As a convenience, the formatter can also be registered at that key,
# rather than needing a second lookup.

# Return the last class descriptor for a path. e.g: for 'Employee.name' return Employee,
# and for 'Employee.department' return Department.
# :: PathInfo -> Table
lastCd = (path) ->
  if path.isAttribute() then path.getParent().getType() else path.getType()

# Get the full bottom up inheritance hierarchy, including the class itself.
getAncestors = (path) ->
  cd = lastCd path
  [cd.name].concat model.getAncestorsOf cd

bool = (x) -> !!x # boolean type coercion.

# Get the formatter for a given path, or null if there isn't one, or false it is disabled.
# :: PathInfo -> Function | null | false
exports.getFormatter = getFormatter = (path) ->
  throw new Error('No path or path is root') if (not path?) or path.isRoot()

  model         = path.model # we need to query the path's model.
  formattersFor = (Options.get ['Formatters', model.name]) ? {}
  ancestors     = getAncestors path
  fieldName     = path.end.name # eg. 'name', 'employees'

  for a in ancestors
    # find formatters registered against specific fields or whole classes.
    # formatters must be registed in this way to apply to one or more paths.
    formatter = (formattersFor["#{ a }.#{ fieldName }"] or formattersFor["#{ a }.*"] )
    if formatter is true
      # formatters are either an object or a boolean - if true, then we can lookup
      # against the class name itself.
      formatter = formattersFor[a]
    return formatter if formatter? # if set to `false` then we short-cut nicely.
  return null

# Return true if we should format a path.
# This is a convenience for a null check on a formatter retrieval, along with
# an attribute check.
# :: (PathInfo) -> bool
exports.shouldFormat = (path) ->
  throw new Error('no path') unless path?
  return false unless path.isAttribute() # we should only format attributes.
  # We should format if there is a formatter available to use (and it isn't disabled).
  bool getFormatter path
