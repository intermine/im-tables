define 'formatters/bio/core/organism', ->

  Organism = (model, query, $cell) ->
    id = model.get 'id'
    @$el.addClass 'organism'
    templ = _.template """
      <span class="name"><%- shortName %></span>
    """
    unless (model.has('shortName') and model.has('taxonId'))
      model._formatter_promise ?= @options.query.service.findById 'Organism', id
      model._formatter_promise.done (org) ->
        model.set org

    data = _.extend {shortName: ''}, model.toJSON()
    templ data
