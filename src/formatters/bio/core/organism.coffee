define 'formatters/bio/core/organism', ->

  templ = _.template """<span class="name"><%- shortName %></span>"""
  needs = ['shortName', 'taxonId']

  Organism = (model, query, $cell) ->
    @$el.addClass 'organism'
    unless model._fetching? or _.all(needs, (n) -> model.has n)
      model._fetching = p = @options.query.service.findById 'Organism', model.get 'id'
      p.done (org) -> model.set org

    data = _.extend {shortName: ''}, model.toJSON()
    templ data
