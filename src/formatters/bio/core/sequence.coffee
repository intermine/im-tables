define 'formatters/bio/core/sequence', ->

  lineLength = 40

  SequenceFormatter = (seq) ->
    id = seq.get 'id'
    @$el.addClass 'dna-sequence'
    unless seq.has('residues')
      model.__fetching ?= @model.get('query').service.findById 'Sequence', id
      model.__fetching.then seq.set.bind seq
    
    residues = seq.get( 'residues' ) || ''
    lines = []

    while residues.length > 0
      line = residues.slice 0, lineLength
      rest = residues.slice lineLength
      lines.push line
      residues = rest

    ("<code>#{ line }</code>" for line in lines).join("<br/>")
