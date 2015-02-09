module.exports = getLeaves = (o, exceptList) ->
  values = (leaf for name, leaf of o when leaf? and name not in exceptList)
  attrs = (v for v in values when not v.objectId?)
  refs = (v for v in values when v.objectId?)
  refs.reduce ((ls, ref) -> ls.concat(getLeaves(ref, exceptList))), attrs
