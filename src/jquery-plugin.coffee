jQuery.fn.imWidget = (arg0, arg1) ->
    if typeof(arg0) is 'string'
        view = @data 'widget'
        if arg0 is 'option'
            switch arg1
                when 'query' then view.query
                when 'service' then view.service
                when 'events' then view.queryEvents
                when 'type' then @data 'widget-type'
                when 'properties' then @data 'widget-options'
                else
                    throw new Error("Unknown option #{ arg1 }")
        else if arg0 is 'table'
            view
        else
            throw new Error("Unknown method #{arg0}")
    else
        {type, service, url, token, query, events, properties, error} = arg0
        service ?= new intermine.Service root: url, token: token
        service.errorHandler = error if error?
        if type is 'table'
            cls = intermine.query.results.CompactView
            view = new cls service, query, events, properties
            @empty().addClass('bootstrap').append view.el
            view.render()
        else if type is 'dashboard'
            cls = intermine.query.results.DashBoard
            view = new cls service, query, events, properties
            @empty().append view.el
            view.render()
        else
            console.error "#{ type } widgets are not supported"

        @data 'widget-options', properties
        @data 'widget-type', type
        @data 'widget', view
        @data 'widget'



