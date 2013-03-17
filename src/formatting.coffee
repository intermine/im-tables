
scope "intermine.results", {
    getFormatter: (model, type) ->
        formatter = null
        unless type?
          [model, type] = [model.model, model.getParent()?.getType()]
        type = type.name or type
        types = [type].concat model.getAncestorsOf(type)
        formatter or= intermine.results.formatters[t] for t in types
        return formatter

    shouldFormat: (path, formatSet) ->
      return false unless path.isAttribute()
      model = path.model
      formatSet ?= model.name
      cd = if path.isAttribute() then path.getParent().getType() else path.getType()
      fieldName = path.end.name
      formatterAvailable = intermine.results.getFormatter(path.model, cd)?

      return false unless formatterAvailable
      return true if fieldName is 'id'
      ancestors = [cd.name].concat path.model.getAncestorsOf cd.name
      formats = intermine.results.formatsets[formatSet] ? {}
      
      for a in ancestors
        return true if (formats["#{a}.*"] or formats["#{ a }.#{fieldName}"])
      return false

}

