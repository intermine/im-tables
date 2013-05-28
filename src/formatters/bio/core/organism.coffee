define 'formatters/bio/core/organism', ->

  templ = _.template """<span class="name"><%- shortName %></span>"""

  Organism = (model, query, $cell) ->
    @$el.addClass 'organism'
    unless model._fetching? or model.has('shortName')
      model._fetching = p = @options.query.service.findById 'Organism', model.get 'id'
      p.done (org) -> model.set org

    defaults = shortName: (model.get('name') or '')

    data = _.extend defaults, model.toJSON()
    templ data
