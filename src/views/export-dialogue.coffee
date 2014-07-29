Promise = require 'promise'
_ = require 'underscore'

{getPermaQuery} = require '../services/perma-query'
Options = require '../options'

EXPORT_FORMATS = [
    {name: "Spreadsheet (tab separated values)", extension: "tsv", param: "tab"},
    {name: "Spreadsheet (comma separated values)", extension: "csv"},
    {name: "XML", extension: "xml"},
    {name: "JSON", extension: "json"},
]

BIO_FORMATS = [
    {
      name: "GFF3 (General Feature Format)",
      extension: "gff3",
      types: ["SequenceFeature"]
    },
    {
      name: "UCSC-BED (Browser Extensible Display Format)",
      extension: "bed", types: ["SequenceFeature"]
    },
    {name: "FASTA sequence", extension: "fasta", types: ["SequenceFeature", "Protein"]}
]

DELENDA = [
    'requestInfo', 'state', 'exportedCols', 'possibleColumns',
    'seqFeatures', 'fastaFeatures', 'extraAttributes'
]

ENTER = 13
SPACE = 32

formatByExtension = (ext) -> _.find EXPORT_FORMATS.concat(BIO_FORMATS), (f) -> f.extension is ext
toPath = (col) -> col.get 'path'
idAttr = (path) -> path.append 'id'
isIncluded = (col) -> col.get('included')
isntExcluded = (col) -> not col.get('excluded')
featuresToPaths = (features) -> features.filter(isIncluded).map(_.compose idAttr, toPath)

isImplicitlyConstrained = (q, node) ->
  return true if q.isInView node
  n = node.toString()
  for v in q.views
    return true if 0 is v.indexOf n
  for c in q.constraints
    return true if c.op and 0 is c.path.indexOf n
  return false

anyAny = (xs, ys, f) -> _.any xs, (x) -> _.any ys, (y) -> f x, y

anyNodeIsSuitable = (model, nodes) -> (types) -> anyAny types, nodes, (t, n) ->
  n.name in model.getSubclassesOf t

# TODO
Exporters = require '../services/exporters'

class exports.ExportDialogue extends Backbone.View

  tagName: 'div'

  className: 'modal im-export-dialogue'

  initialize: (query) ->
    @query = query.clone() # Take snapshot, not reference.
    @service = query.service
    @dummyParams = ['allRows', 'allCols', 'end', 'columnHeaders']
    @qids = {}
    @requestInfo = new Backbone.Model
      format: EXPORT_FORMATS[0]
      allRows: true
      allCols: true
      start: 0
      compress: "no"
      columnHeaders: true

    # TODO
    for name, enabled of Options.ExternalExportDestinations when enabled
      Exporters.external[name].init?.call(@)

    # TODO - not finished....

