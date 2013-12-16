module.exports = getReplacedTest = (replacedBy, explicitReplacements) -> (col) ->
  p = col.path
  return false unless intermine.results.shouldFormat(p) or explicitReplacements[p]
  replacer = replacedBy[p]
  replacer ?= replacedBy[p.getParent()] if p.isAttribute() and p.end.name is 'id'
  replacer and replacer.formatter? and col isnt replacer

