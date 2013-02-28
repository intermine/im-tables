scope "intermine.options",
    MAX_PIE_SLICES: 15,
    GalaxyMain: "http://main.g2.bx.psu.edu"
    ShowId: false
    TableWidgets: ['Pagination', 'PageSizer', 'TableSummary', 'ManagementTools', 'ScrollBar']
    CDN: # CDN resources that can be configured.
      server: 'http://cdn.intermine.org'
      resources:
        prettify: [
          '/js/google-code-prettify/latest/prettify.js',
          '/js/google-code-prettify/latest/prettify.css'
        ]
        d3: '/js/d3/3.0.6/d3.v3.min.js'
    
    D3:
      Transition:
        Easing: 'elastic'
        Duration: 750

do ->
  doLoad = (server, resource) ->
    if /\.css$/.test resource
      link = jQuery('<link type="text/css" rel="stylesheet">')
      link.appendTo('head').attr href: server + resource
      return jQuery.Deferred -> @resolve()
    else
      return jQuery.ajax
        url: server + resource
        cache: true
        dataType: 'script'

  scope 'intermine.cdn',

    load: (ident) ->
      {server, resources} = intermine.options.CDN
      conf = resources[ident]
      if not conf
        jQuery.Deferred -> @reject "No resource is configured for #{ ident }"
      else if _.isArray(conf)
        doLoad(server, r) for r in conf
      else
        doLoad(server, conf)


