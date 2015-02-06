module.exports = getLeaves = (o, exceptList) ->
  leaves = []
  values = (leaf for name, leaf of o when name not in exceptList)
  for x in values
    if x.objectId
      leaves = leaves.concat(getLeaves(x))
    else
      leaves.push(x)
  leaves

