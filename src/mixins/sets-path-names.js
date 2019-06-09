## Requires @query :: Query, @view :: PathInfo
## sets @state{typeName, pathName, endName, error}
exports.setPathNames = ->
  q = (@query ? @model.query)
  v = (@view ? @model.view)
  service = q.service
  type = v.getParent().getType()
  end = v.end
  s = @state
  set = (prop) -> (val) -> s.set prop, val
  setError = set 'error'
  v.getDisplayName().then (set 'pathName'), setError
  type.getDisplayName().then (set 'typeName'), setError
  service.get "model/#{ type.name }/#{ end.name }"
         .then ({name}) -> name # cf. {display}
         .then (set 'endName'), setError
