simpleFormatter = require '../../utils/simple-formatter'

[chr] = FIELDS = ['locatedOn.primaryIdentifier', 'start', 'end']
formatter = (loc) -> "#{ loc[chr] }:#{ loc.start }..#{ loc.end }"
classes = 'monospace-text'

module.exports = simpleFormatter 'Location', FIELDS, formatter, classes
