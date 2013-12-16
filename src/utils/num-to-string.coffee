_ = require 'underscore'

# TODO: unit tests
module.exports = numToString = (num, sep, every) ->
    rets = []
    i = 0
    chars =  (num + "").split("")
    len = chars.length
    groups = _(chars).groupBy (c, i) -> Math.floor((len - (i + 1)) / every).toFixed()
    while groups[i]
        rets.unshift groups[i].join("")
        i++
    return rets.join(sep)
