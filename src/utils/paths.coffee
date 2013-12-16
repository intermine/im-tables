pos = (substr) -> _.memoize (str) -> str.toLowerCase().indexOf substr
pathLen = _.memoize (str) -> str.split(".").length

exports.lengthSorter = (items) ->
    getPos = pos @query.toLowerCase()
    items.sort (a, b) ->
        if a is b
            0
        else
            getPos(a) - getPos(b) || pathLen(a) - pathLen(b) || if a < b then -1 else 1
    return items

exports.matcher = (item) ->
    lci = item.toLowerCase()
    terms = (term for term in @query.toLowerCase().split(/\s+/) when term)
    item and _.all terms, (t) -> lci.match(t)

exports.highlighter = (item) ->
    terms = @query.toLowerCase().split(/\s+/)
    for term in terms when term
        item = item.replace new RegExp(term, "gi"), (match) -> "<>#{ match }</>"
    item.replace(/>/g, "strong>")
