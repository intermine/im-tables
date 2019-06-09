# We may still need these...
modelIsBio = (model) -> !!model?.classes['Gene']

requiresAuthentication = (q) -> _.any q.constraints, (c) -> c.op in ['NOT IN', 'IN']

organisable = (path) ->
  path.getEndClass().name is 'Organism' or path.getType().fields['organism']?

getOrganisms = (q, cb) -> $.when(q).then (query) ->
  def = $.Deferred()
  def.done cb if cb?
  done = _.compose def.resolve, uniquelyFlat

  mustBe = ((c.value or c.values) for c in query.constraints when (
    (c.op in ['=', 'ONE OF', 'LOOKUP']) and c.path.match(/(o|O)rganism(\.\w+)?$/)))

  if mustBe.length
    done mustBe
  else
    toRun = query.clone()
    newView = for n in toRun.getViewNodes() when organisable n
      opath = if n.getEndClass().name is 'Organism' then n else n.append('organism')
      opath.append 'shortName'

    if newView.length
      toRun.select(_.uniq newView, String)
            .orderBy([])
            .rows()
            .then(done, -> done [])
    else
      done []

  return def.promise()
