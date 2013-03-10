do ->
  SVG = "http://www.w3.org/TR/SVG11/feature#Shape"
  supportsSVG = ->
    window.SVGAngle? or document.implementation?.hasFeature?(SVG, "1.0")

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
          if supportsSVG() and not d3?
            # Can be loaded late, as only needed for summaries, which the
            # user will have to click on.
            intermine.cdn.load 'd3'
            
          service ?= new intermine.Service root: url, token: token
          service.errorHandler = error if error?
          cls = if type is 'table'
            intermine.query.results.CompactView
          else if type is 'dashboard'
            intermine.query.results.DashBoard

          unless cls
            console.error "#{ type } widgets are not supported"
            return false

          view = new cls service, query, events, properties
          @empty().append view.el
          view.render()

          @data 'widget-options', properties
          @data 'widget-type', type
          @data 'widget', view
          @data 'widget'



