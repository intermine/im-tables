_ = require 'underscore'

exports.initTypeaheads = -> @_typeaheads ?= []

exports.removeTypeAheads = ->
  return unless @_typeaheads?
  while (ta = @_typeaheads.shift())
    ta.off('typeahead:select')
    ta.off('typeahead:selected')
    ta.off('typeahead:autocompleted')
    ta.off('typeahead:close')
    ta.typeahead('destroy')

exports.lastTypeahead = -> _.last(@_typeaheads ? [])

# @param input [jQuery] A jQuery selection to apply a typeahead to.
# @param opts [Object] The typeahead options (see http://twitter.github.io/typeahead.js/examples/)
# @param data [(String, ([String]) ->) ->] Data source
# @param placeholder [String] The new place-holder
# @param cb [(Event, Object) ->] Suggestion handler
exports.activateTypeahead = (input, opts, data, placeholder, cb, onChange) ->
  input.attr(placeholder: placeholder).typeahead opts, data
  input.on 'typeahead:selected', cb
  input.on 'typeahead:select', cb
  input.on 'typeahead:autocompleted', cb
  if onChange?
    input.on 'typeahead:close', onChange

  # Keep a track of it, so it can be removed.
  @initTypeaheads().push input

  input.focus()

  this


