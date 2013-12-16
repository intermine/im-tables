_ = require 'underscore'
{uniquelyFlat} = require './unterstrich'
{utils: {success}} = require 'imjs'

bool = (x) -> !! x

# Returns true if the model is a genomic model.
exports.modelIsGenomic = (model) -> bool model?.classes['Gene']

# Return true if the path refers to an Organism or if the type the
# path refers to has an organism field.
exports.organisable = organisable = (path) ->
  path.getEndClass().name is 'Organism' or path.getType().fields['organism']?

getOrganisms = (query, cb) ->
  mustBe = ((c.value or c.values) for c in query.constraints when (
    (c.op in ['=', 'ONE OF', 'LOOKUP']) and c.path.match(/(o|O)rganism(\.\w+)?$/)))

  if mustBe.length
    success uniquelyFlat mustBe
  else
    toRun = query.clone()
    newView = for n in toRun.getViewNodes() when organisable n
      opath = if n.getEndClass().name is 'Organism' then n else n.append('organism')
      opath.append 'shortName'

    if newView.length
      toRun.select(_.uniq newView, String)
            .orderBy([]) # Clear sort order
            .rows()
            .then uniquelyFlat, -> []
    else
      success []
