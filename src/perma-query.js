define 'perma-query', ->

  {get}  = intermine.funcutils
  {any, zip} = _
  {Deferred} = jQuery
  defer = (x) -> Deferred -> @resolve x
  whenAll = (promises) -> $.when.apply($, promises).then (results...) -> results.slice()

  replaceIdConstraint = (classkeys, query) -> (c) ->
    path = query.makePath c.path
    def = new Deferred
    if not ( c.op in ['=', '=='] and path.end.name is 'id' )
      def.resolve c
    else
      type = path.getParent().getType().name
      keys = classkeys[type]
      if not keys?
        def.reject "No class keys configured for #{ type }"
      else
        finding = query.service.rows(select: keys, where: {id: c.value}).then get 0
        finding.fail def.reject
        finding.then (values) ->
          return def.reject("#{ type }@#{ c.value } not found") unless values
          for [path, value] in zip(keys, values) when value?
            return def.resolve {path, value, op: '=='} # Must be ==, because symbols.
          def.reject("#{ type }@#{ c.value } has no identifying fields")

    def.promise()

  getPermaQuery = (query) ->
    nodes = (query.makePath c.path for c in query.constraints when not c.type?)
    containsIdConstraint = nodes.length and any nodes, (n) -> 'id' is n.end?.name
    copy = query.clone()
    return defer copy unless containsIdConstraint
    def = new Deferred
    applyNewCons = (newCons) ->
      copy.constraints = newCons
      def.resolve copy
    query.service.get('classkeys').then ({classes}) ->
      replaceIdCon = replaceIdConstraint classes, copy
      whenAll(replaceIdCon(c) for c in copy.constraints).then(applyNewCons).fail def.reject
    return def.promise()

