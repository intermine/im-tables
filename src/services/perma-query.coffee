Promise = require 'promise'
{any, zip} = require 'underscore'

defer = (x) -> new Promise (resolve, reject) -> resolve x
reject = (x) -> new Promise (resolve, reject) -> reject x

get = (x) -> (o) -> o[x]

ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')

# :: (Map<ClassName, Array<Path>>, Query) -> Constraint{path, op, value}
#                                         -> Promise<Array<Constraint>>
replaceIdConstraint = (classKeys, query) -> (c) ->
  path = query.makePath c.path
  return defer [c] if not (c.op in ['=', '=='] and path.end.name is 'id')
  type = path.getParent().getType().name
  keys = classKeys[type]
  return reject new Error "No class keys configured for #{ type }" if not keys?
  query.service
    .rows(select: keys, where: {id: c.value})
       .then(get 0)
       .then (props) ->
         return reject "#{ type }@#{ c.value } not found" unless props
         # Strict equality for case-sensitive symbols
         cons = ({path, value, op: '=='} for [path, value] in zip(keys, props) when value?)
         return if cons.length then cons else reject "#{ type }@#{ c.value } has no properties"

applyNewCons = (query) -> (constraints) ->
  remainingCodes = _.difference ALPHABET, (c.code for c in query.constraints when c.code?)
  nextCode = -> remainingCodes.shift()
  for [oldCon, conSet] in zip(query.constraints, constraints)
    if conSet.length is 1
      newCon = conSet[0]
      newCon.code = oldCon.code
      logic = query.constraintLogic
      query.removeConstraint newCon.code
      query.addConstraint newCon
      query.constraintLogic = logic
    else
      for c in conSet
        c.code = nextCode()
      logic = query.constraintLogic.replace(/AND/gi, '&').replace(/OR/gi, '|')
      re = new Regexp(oldCon.code, 'g')
      logic = logic.replace re, "(#{ (c.code for c in conSet).join(' AND ') })"
      logic = logic.replace(/&/g, 'AND').replace(/|/g, 'OR')
      query.removeConstraint oldCon.code
      for c in conSet
        query.addConstraint c
      query.constraintLogic = logic

  return query

# :: {constraints :: Array<Constraint>, constraintLogic :: String} -> that (Mutator)
ensureCodedConstraints = (query) ->
  remainingCodes = _.difference ALPHABET, (c.code for c in query.constraints when c.code?)
  for c in query.constraints when not c.type? and not c.code
    c.code = remainingCodes.shift()
  if not query.constraintLogic
    query.constraintLogic = (c.code for c in query.constraints).join ' AND '
  return query

# :: (Query) -> Promise<Query>
exports.getPermaQuery = (query) ->
  nodes = (query.makePath c.path for c in query.constraints when not c.type?)
  containsIdConstraint = nodes.length and any nodes, (n) -> 'id' is n.end?.name
  copy = ensureCodedConstraints query.clone()
  return defer copy unless containsIdConstraint
  query.service.get('classkeys').then ({classes}) ->
    replaceIdCon = replaceIdConstraint classes, copy
    Promise.all(replaceIdCon c for c in copy.constraints).then(applyNewCons copy)

