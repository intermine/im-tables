
scope "intermine.results", {
    getFormatter: (path) ->
      return null unless path?
      cd = if path.isAttribute() then path.getParent().getType() else path.getType()
      ancestors = [cd.name].concat path.model.getAncestorsOf cd.name
      formats = intermine.results.formatsets[path.model.name] ? {}
      fieldName = path.end.name
      for a in ancestors
        formatter = (formats["#{a}.*"] or formats["#{ a }.#{fieldName}"])
        if formatter is true
          formatter = intermine.results.formatters[a]
        return formatter if formatter?
      return null

    shouldFormat: (path, formatSet) ->
      return false unless path.isAttribute()
      model = path.model
      formatSet ?= model.name
      cd = if path.isAttribute() then path.getParent().getType() else path.getType()
      fieldName = path.end.name
      formatterAvailable = intermine.results.getFormatter(path)?

      return false unless formatterAvailable
      return true if fieldName is 'id'
      ancestors = [cd.name].concat path.model.getAncestorsOf cd.name
      formats = intermine.results.formatsets[formatSet] ? {}
      
      for a in ancestors
        return true if (formats["#{a}.*"] or formats["#{ a }.#{fieldName}"])
      return false

}

