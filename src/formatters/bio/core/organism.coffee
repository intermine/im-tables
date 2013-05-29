define 'formatters/bio/core/organism', ->

  getData = (model, prop, backupProp) ->
    ret = {}
    val = ret[prop] = model.get prop
    unless val?
      ret[prop] = model.get backupProp
    return ret

  ensureData = (model, service) ->
    return if model._fetching? or model.has 'shortName'
    model._fetching = p = service.findById 'Organism', model.get 'id'
    p.done (org) -> model.set org

  templ = _.template """<span class="name"><%- shortName %></span>"""

  Organism = (model) ->
    @$el.addClass 'organism'
    ensureData model, @options.query.service

    data = getData model, 'shortName', 'name'
    templ data
