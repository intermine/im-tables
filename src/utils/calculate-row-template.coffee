# Analyse the select list to establish what the columns are going to be,
# based on the outer joined structure.

# Find the highest outer-joined collection below a given value.
getOJCBelow = (query, p, below) ->
  oj = query.getOuterJoin p
  return null if (not oj) or (oj is below) # not outerjoined, or joined at the target level.
  path = query.makePath(oj)
  # outer loop variables.
  highest = if path.isCollection() then oj else null
  path = path.getParent()

  while path and (not path.isRoot()) then do (next = query.getOuterJoin path) ->
    nextPath = query.makePath(next) if next?
    highest = next if nextPath?.isCollection() and (next isnt below)
    path = nextPath?.getParent()

  return highest

getTopLevelOJC = (query, p) -> getOJCBelow query, p, null

module.exports = calculateRowTemplate = (query) ->
  row = []
  handled = {}
  for v in query.views when (not handled[v])
    oj = getTopLevelOJC query, v
    if oj
      coevals = query.views.filter (vv) -> oj is getTopLevelOJC query, vv
      group = {column: oj, view: []}
      for cv in coevals # Either add subviews or subgroups.
        lower = getOJCBelow query, cv, oj # Find the highest oj for this path below the top level.
        handled[cv] = group # This view is handled by this group.
        if lower
          group.view.push(lower) unless (lower in group.view) # only add once.
        else
          group.view.push cv
      row.push(handled[oj] = group)
    else
      row.push(handled[v] = {column: v})
  return row

