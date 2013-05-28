define 'formatters/bio/core/organism', ->

  getData = (model, prop, backupProp) ->
    ret = {}
    val = ret[prop] = model.get prop
    ret[prop] = model.get(backupProp) unless val?
    return ret

  fetchMissing = (model, service) ->
    return if model._fetching?
    model._fetching = p = service.findById 'Organism', model.get 'id'
    p.done (org) -> model.set org

  templ = _.template """<span class="name"><%- shortName %></span>"""

  Organism = (model) ->
    @$el.addClass 'organism'
    fetchMissing(model, @options.query.service) unless model.has('shortName')

    data = getData model, 'shortName', 'name'
    templ data
