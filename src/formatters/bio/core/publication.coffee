define 'formatters/bio/core/publication', ->

  PublicationFormatter = (imobject) ->
    id = imobject.get 'id'
    @$el.addClass 'publication'
    unless imobject.has('title') and imobject.has('firstAuthor') and imobject.has('year')
      imobject.__fetching ?= @model.get('query').service.findById 'Publication', id
      imobject.__fetching.then (pub) -> imobject.set pub

    {title, firstAuthor, year} = imobject.toJSON()
    "#{title} (#{firstAuthor}, #{year})"

  PublicationFormatter.replaces = [ 'title', 'firstAuthor', 'year' ]

  PublicationFormatter
