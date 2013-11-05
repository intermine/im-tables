define 'formatters/bio/core/sequence', ->

  lineLength = 40

  SequenceFormatter = (model) ->
    id = model.get 'id'
    @$el.addClass 'dna-sequence'
    unless model.has('residues')
      model._formatter_promise ?= @options.query.service.findById 'Sequence', id
      model._formatter_promise.done (seq) -> model.set seq
    
    sequence = model.get( 'residues' ) || ''
    lines = []

    while sequence.length > 0
      line = sequence.slice 0, lineLength
      rest = sequence.slice lineLength
      lines.push line
      sequence = rest

    ("<code>#{ line }</code>" for line in lines).join("<br/>")
