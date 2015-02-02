# Analyse the select list to establish what the columns are going to be,
# based on the outer joined structure.
module.exports = calculateRowTemplate = (query) ->
  row = []
  handled = {}
  row = for v in query.views when (not handled[v])
    oj = query.getOuterJoin v
    isOjColl = if oj then query.makePath(oj).isCollection() else false
    if isOjColl
      coevals = (vv for vv in query.views when query.getOuterJoin(vv) is oj)
      group = {column: oj, view: coevals}
      for cv in coevals
        handled[cv] = group
      group
    else
      handled[v] = {column: v}
  return row

