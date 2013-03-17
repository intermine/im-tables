
scope "intermine.results.formatters",
    Manager: (model) ->
      id = model.get 'id'
      needs = ['title', 'name']
      unless model._fetching? or _.all(needs, (n) -> model.has n)
        model._fetching = p = @options.query.service.findById 'Manager', id
        p.done (manager) -> model.set manager
      
      data = _.defaults model.toJSON(), {title: '', name: ''}

      _.template "<%- title %> <%- name %>", data

scope 'intermine.results.formatsets.testmodel',

  'Manager.name': true
