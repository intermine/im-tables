$ = require 'jquery'

# Code under test:
Options = require 'imtables/options'
Dashboard  = require 'imtables/views/dashboard'
Formatting = require 'imtables/formatting'
clf = require 'imtables/formatters/genomic/location'

# Test helpers.
renderQuery = require '../lib/render-query.coffee'
{genomic} = require '../lib/connect-to-service'

# Make these toggleable...
Options.set 'TableCell.IndicateOffHostLinks', false

console.log 'Registering formatter for', clf.target, clf.replaces
Formatting.registerFormatter clf, 'genomic', clf.target, clf.replaces

withQuery = (h2, div, query) ->
  dash = new Dashboard {query, model: {size: 15}}
  div.appendChild dash.render().el

QUERY =
  name: 'Bio Query'
  select: [
    'primaryIdentifier',
    'chromosomeLocation.start',
    'chromosomeLocation.end',
    'chromosomeLocation.locatedOn.primaryIdentifier',
    'proteins.primaryAccession'
  ]
  from: 'Gene'

$ -> renderQuery withQuery, genomic, QUERY
