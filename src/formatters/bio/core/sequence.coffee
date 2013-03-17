define 'formatters/bio/core/sequence', ->

  SequenceFormatter = (model) ->
    id = model.get 'id'
    @$el.addClass 'dna-sequence'
    unless model.has('residues')
      model._formatter_promise ?= @options.query.service.findById 'Sequence', id
      model._formatter_promise.done (seq) -> model.set seq
    
    sequence = model.get( 'residues' ) || ''
    lines = []

    while sequence.length > 0
      line = sequence.slice 0, 80
      rest = sequence.slice 80
      lines.push line
      sequence = rest

    lines.join("\n")
