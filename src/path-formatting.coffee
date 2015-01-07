Options = require './options'

# Get the formatter for the given path in the named model.
# @param path [PathInfo] The path to look for a formatter for
# @param modelName [String] (optional) The model name (defaults to the name of the path's model)
exports.getFormatter = getFormatter = (path, modelName) ->
  return null unless path? # The formatter of nothing is nothing.
  cd = if path.isAttribute() then path.getParent().getType() else path.getType()
  ancestors = [cd.name].concat path.model.getAncestorsOf cd.name
  modelName ?= model.name
  formatters = (Options.get ['Formatters', modelName]) ? {}
  fieldName = path.end.name

  for className in ancestors # list of class names.
    # Prefer specific formatters to general ones.
    formatter = (formatters["#{ className }.#{ fieldName }"] or formatters["#{ className }.*"])
    
    # return if found, otherwise - keep looking.
    if formatter is true # true indicates that the formatter is keyed by the class name.
      return formatters[a]
    else if formatter?
      return formatter

  return null

# Simple alias that just checks that there is a formatter for the path.
exports.shouldFormat = (path, modelName) ->
  return getFormatter(path, modelName)?

# Register a formatter designed to handle a single path.
exports.registerFormatter = register = (modelName, path, formatter) ->
  Options.set ['Formatters', modelName, path], formatter

# Register a formatter designed to handle any field of a class.
exports.registerGeneralFormatter = (modelName, className, formatter) ->
  Options.set ['Formatters', modelName, "#{ className }.*"], true
  register modelName, className, formatter

