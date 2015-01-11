## Requires @query :: Query, @view :: PathInfo
## sets @state{typeName, pathName, endName, error}
exports.setPathNames = ->
  service = @query.service
  type = @view.getParent().getType()
  end = @view.end
  s = @state
  set = (prop) -> (val) -> s.set prop, val
  setError = set 'error'
  type.getDisplayName().then (set 'typeName'), setError
  view.getDisplayName().then (set 'pathName'), setError
  service.get "model/#{ type.name }/#{ end.name }"
         .then ({name}) -> name # cf. {display}
         .then (set 'endName'), setError
