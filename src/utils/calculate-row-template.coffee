# Analyse the select list to establish what the columns are going to be,
# based on the outer joined structure.

# Find the highest outer-join below a given value.
getOJBelow = (query, p, below) ->
  oj = query.getOuterJoin p
  return null if (not oj) or (oj is below) # not outerjoined, or joined at the target level.
  highest = oj
  path = query.makePath(oj).getParent()
  while path and (not path.isRoot())
    next = query.getOuterJoin path
    if next and (next isnt below)
      highest = next
      path = query.makePath(next).getParent()
    else
      path = null
  return highest

getTopLevelOJ = (query, p) -> getOJBelow query, p, null

module.exports = calculateRowTemplate = (query) ->
  row = []
  handled = {}
  for v in query.views when (not handled[v])
    oj = getTopLevelOJ query, v
    isOjColl = if oj then query.makePath(oj).isCollection() else false
    if isOjColl
      coevals = query.views.filter (vv) -> oj is getTopLevelOJ query, vv
      console.log "all views within #{ oj }", coevals
      group = {column: oj, view: []}
      for cv in coevals # Either add subviews or subgroups.
        lower = getOJBelow query, cv, oj # Find the highest oj for this path below the top level.
        handled[cv] = group # This view is handled by this group.
        console.log "lower of #{ cv } is #{ lower }"
        if lower
          group.view.push(lower) unless (lower in group.view) # only add once.
        else
          group.view.push cv
      row.push(handled[oj] = group)
    else
      row.push(handled[v] = {column: v})
  return row

