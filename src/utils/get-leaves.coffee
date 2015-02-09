module.exports = getLeaves = (o, exceptList) ->
  leaves = []
  values = (leaf for name, leaf of o when name not in exceptList)
  for x in values when x?
    if x.objectId
      leaves = leaves.concat(getLeaves(x, exceptList))
    else
      leaves.push(x)
  leaves

