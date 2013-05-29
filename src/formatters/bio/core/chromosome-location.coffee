define 'formatters/bio/core/chromosome-location', ->

  fetch = (service, id) ->
    service.rows
      from: 'Location'
      select: ChrLocFormatter.replaces
      where: {id}

  class ChrLocFormatter

    @replaces: ['locatedOn.primaryIdentifier', 'start', 'end', 'strand']

    @merge: (location, chromosome) ->
      if chromosome.has 'primaryIdentifier'
        location.set chr: chromosome.get('primaryIdentifier')

    constructor: (model) ->
      id = model.get 'id'
      @$el.addClass 'chromosome-location'
      needs = ['start', 'end', 'chr']
      unless model._fetching? or _.all(needs, (n) -> model.has n)
        model._fetching = fetch @options.query.service, id
        model._fetching.done ([[chr, start, end]]) ->
          model.set {chr, start, end}
      
      {start, end, chr} = model.toJSON()
      return "#{chr}:#{start}-#{end}"

