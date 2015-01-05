_ = require 'underscore'
{Promise} = require 'es6-promise'

uniquelyFlat = _.compose _.uniq, _.flatten

# A path has an organism if it can have the 'organism' segment appended, e.g. 'Gene'
hasAnOrganism = (path) -> path.getType().fields?.organism?

# A path is organisable if it refers to an Organism, or something that has an .organism
organisable = (path) ->
  (path.getEndClass().name is 'Organism') or (hasAnOrganism path)

# Test if path refers to one of the paths we want.
nameOrShortName = (path) ->
  (path.getEndClass().name is 'Organism') and (path.end.name in ['name', 'shortName'])

# Value is wild if it includes a wildcard ('*')
wild = (value) -> value? and /\*/.test value

# The equality operators
EQL = ['=', '==', 'ONE OF']

# Determine the organisms a query refers to
# :: (Query) -> Promise<Array<Organism.shortName>>
# Assumes that Organism.shortName (string) exists in the model.
module.exports = getOrganisms = (query) -> new Promise (resolve, reject) ->
  done = _.compose resolve, uniquelyFlat # Flatten and remove duplicates before resolution.
  nothing = -> resolve []                # resolve with the empty list on error/failure.

  # either paths constrained directly (eg. Organism.name = Drosophila melanogaster)
  directly = ((c.value or c.values) for c in query.constraints when (
    (c.op in EQL) and (not wild c.value) and (nameOrShortName query.makePath c.path)))
  # Or the extra value of lookup constraints on paths that have an
  # organism (e.g. Gene LOOKUP 'foo')
  onLookups = (c.extraValue for c in query.constraints when (
    (c.op is 'LOOKUP') and c.extraValue? and (hasAnOrganism query.makePath c.path)))
  # If we are constrained to one or more organisms, then we assume it must be one of those.
  mustBe = _.union directly, onLookups

  if mustBe.length
    done mustBe
  else
    newView = for n in query.getViewNodes() when organisable n
      opath = if n.getType().name is 'Organism' then n else n.append('organism')
      opath.append 'shortName'

    if newView.length
      query.clone()
           .select(_.uniq newView, String)
           .orderBy([])
           .rows()
           .then(done, nothing)
    else
      nothing()
