exports.ignore = (e) ->
  e?.preventDefault()
  e?.stopPropagation()
  return false
