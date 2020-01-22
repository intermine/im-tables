define 'formatters/bio/core/chromosome-location', ->

  fetch = (service, id) ->
    service.rows
      from: 'Location'
      select: ChrLocFormatter.replaces
      where: {id}

  class ChrLocFormatter

    @replaces: ['locatedOn.primaryIdentifier', 'start', 'end']

    @merge: (location, chromosome) ->
      if chromosome.has 'primaryIdentifier'
        location.set chr: chromosome.get('primaryIdentifier')

    constructor: (imobject) ->
      id = imobject.get 'id'
      @$el.addClass 'chromosome-location'
      needs = ['start', 'end', 'chr']
      unless imobject.__fetching? or _.all(needs, (n) -> imobject.has n)
        imobject.__fetching = fetch @model.get('query').service, id
        imobject.__fetching.then ([[chr, start, end]]) -> imobject.set {chr, start, end}
      
      {start, end, chr} = imobject.toJSON()
      return "#{chr}:#{start}-#{end}"

