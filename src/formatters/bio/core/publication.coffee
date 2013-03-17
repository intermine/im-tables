define 'formatters/bio/core/publication', ->

  PublicationFormatter = (model) ->
    id = model.get 'id'
    @$el.addClass 'publication'
    unless model.has('title') and model.has('firstAuthor') and model.has('year')
      model._formatter_promise ?= @options.query.service.findById 'Publication', id
      model._formatter_promise.done (pub) -> model.set pub

    {title, firstAuthor, year} = model.toJSON()
    "#{title} (#{firstAuthor}, #{year})"

  PublicationFormatter.replaces = [ 'title', 'firstAuthor', 'year' ]

  PublicationFormatter
