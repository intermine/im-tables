##
# Very naïve English word pluralisation algorithm
#
# @param {String} word The word to pluralise.
# @param {Number} count The number of items this word represents.
##
module.exports = pluralise = (word, count) ->
    if count is 1
        word
    else if word.match /(s|x|ch)$/
        word + "es"
    else if word.match /[^aeiou]y$/
        word.replace /y$/, "ies"
    else
        word + "s"

