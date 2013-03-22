define 'formatters/bio/core/chromosome-location', ->

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
        model._fetching = @options.query.service.findById 'Location', id
        model._fetching.done (loc) ->
          model.set start: loc.start, end: loc.end, chr: loc.locatedOn.primaryIdentifier
      
      {start, end, chr} = model.toJSON()
      return "#{chr}:#{start}-#{end}"

