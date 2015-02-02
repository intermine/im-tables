Collection = require '../core/collection'

class ColumnHeaders extends Collection

  setHeaders: (query) -> query.service.get("/classkeys").then ({classes}) =>
    # need at least one example row - any will do.
    # if there isn't one, then return and wait to be called later.
    return unless @model.get('cache')?.length
    [row] = @model.get 'cache'
    classKeys = classes
    replacedBy = {}
    {longestCommonPrefix, getReplacedTest} = intermine.utils

    # Create the columns
    cols = for cell in row
      path = q.getPathInfo cell.column
      replaces = if cell.view? # subtable of this cell.
        commonPrefix = longestCommonPrefix cell.view
        path = q.getPathInfo commonPrefix
        replaces = (q.getPathInfo(v) for v in cell.view)
      else
        []
      {path, replaces}

    # Build the replacement information.
    for col in cols when col.path.isAttribute() and intermine.results.shouldFormat col.path
      p = col.path
      formatter = intermine.results.getFormatter p
      
      # Check to see if we should apply this formatter.
      if @canUseFormatter formatter
        col.isFormatted = true
        col.formatter = formatter
        for r in (formatter.replaces ? [])
          subPath = "#{ p.getParent() }.#{ r }"
          replacedBy[subPath] ?= col
          col.replaces.push q.getPathInfo subPath if subPath in q.views

    isKeyField = (col) ->
      return false unless col.path.isAttribute()
      pType = col.path.getParent().getType().name
      fName = col.path.end.name
      return "#{pType}.#{fName}" in (classKeys?[pType] ? [])

    explicitReplacements = {}
    for col in cols
      for r in col.replaces
        explicitReplacements[r] = col

    isReplaced = getReplacedTest replacedBy, explicitReplacements

    newHeaders = for col in cols when not isReplaced col
      if col.isFormatted
        col.replaces.push col.path unless col.path in col.replaces
        col.path = col.path.getParent() if (isKeyField(col) or col.replaces.length > 1)
      col

    @columnHeaders.reset newHeaders

