_ = require 'underscore'

exports.uniquelyFlat = _.compose _.uniq, _.flatten
