_ = require 'underscore'

module.exports = class HasTypeaheads

  initTypeaheads: ->
    @_typeaheads ?= []

  removeTypeAheads: ->
    return unless @_typeaheads?
    while (ta = @_typeaheads.shift())
      ta.off('typeahead:selected')
      ta.off('typeahead:autocompleted')
      ta.typeahead('destroy')
      ta.remove()

  lastTypeahead: -> _.last(@_typeaheads ? [])

  activateTypeahead: (input, opts, data, placeholder, cb) ->
    input.attr(placeholder: placeholder).typeahead opts, data
    input.on 'typeahead:selected', cb
    input.on 'typeahead:autocompleted', cb

    # Keep a track of it, so it can be removed.
    @initTypeaheads().push input

    this


