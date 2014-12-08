scope "intermine.options",
    INITIAL_SUMMARY_ROWS: 1000,
    NUM_SEPARATOR: ',',
    NUM_CHUNK_SIZE: 3,
    MAX_PIE_SLICES: 15
    DefaultPageSize: 25
    DefaultCodeLang: 'py'
    ListFreshness: 250 # Number of milliseconds lists requests will be considered fresh for.
    MaxSuggestions: 1000 # Max number of suggestions to fetch and show when editing constraints.
    ListCategorisers: ['organism.name', 'department.company.name']
    PieColors: 'category20'
    CellPreviewTrigger: 'hover' # click
    IndicateOffHostLinks: true
    ExternalLinkIcons:
      "http://some.host.somewhere": "http://some.host.somewhere/logo.png"
    StylePrefix: 'intermine'
    GalaxyMain: "http://main.g2.bx.psu.edu"
    GalaxyCurrent: null
    GalaxyTool: 'flymine'
    GenomeSpaceUpload: "https://gsui.genomespace.org/jsui/upload/loadUrlToGenomespace.html"
    ExternalExportDestinations: # Setting these to false disables them
      Galaxy: true
      Genomespace: true
    ShowId: false
    TableWidgets: ['Pagination', 'PageSizer', 'TableSummary', 'ManagementTools', 'ScrollBar']
    CellCutoff: 100
    ShowHistory: true
    ServerApplicationError:
      Heading: "There was a problem with the request to the server"
      Body: """
        This is most likely related to the query that was just run. If you have
        time, please send us an email with details of this query to help us diagnose and
        fix this bug.
      """
    ClientApplicationError:
      Heading: 'Client application error'
      Body: """
        This is due to an unexpected error in the tables
        application - we are sorry for the inconvenience
      """
    Style:
      icons: 'glyphicons'
    CDN: # CDN resources that can be configured.
      server: 'http://cdn.intermine.org'
      tests:
        fontawesome: /font-awesome/
        glyphicons: /bootstrap-icons/
      resources:
        prettify: [
          '/js/google-code-prettify/latest/prettify.js',
          '/js/google-code-prettify/latest/prettify.css'
        ]
        d3: '/js/d3/3.0.6/d3.v3.min.js'
        glyphicons: "/css/bootstrap/2.3.2/css/bootstrap-icons.css"
        fontawesome: "/css/font-awesome/4.x/css/font-awesome.min.css"
        filesaver: '/js/filesaver.js/FileSaver.min.js'
    
    D3:
      Transition:
        Easing: 'elastic'
        Duration: 750
    brand:
      "http://www.flymine.org": "FlyMine"
      "http://preview.flymine.org": "FlyMine-Preview"
      "http://www.mousemine.org": "MouseMine (MGI)"
    preview: {count: {}}

do ->

  events = _.extend {}, Backbone.Events

  events.on 'change:intermine.options.Style.icons', (iconStyle) ->


  scope 'intermine',

    onChangeOption: (name, cb, ctx) -> events.on "change:intermine.options.#{ name }", cb, ctx

    setOptions: set = (opts, ns = '') ->
      ns = if ns is '' or /^\./.test(ns) then 'intermine.options' + ns else ns
      for key, value of opts
        if _.isObject value
          set value, "#{ ns }.#{ key }"
        else
          o = {}
          o[key] = value
          scope ns, o, true
          events.trigger "change:#{ ns }.#{ key }", value

do ->

  asArray = (things) -> [].slice.call(things)

  hasStyle = (pattern) ->
    return false unless pattern? # No way to tell, assume not.
    links = asArray document.querySelectorAll 'link[rel="stylesheet"]'
    _.any links, (link) -> pattern.test link.href

  parallel = (promises) -> jQuery.when.apply(jQuery, promises)

  loader = (server) -> (resource, resourceRegex) ->
    # scripts will be loaded, but possibly not executed: hang off a bit
    resolution = jQuery.Deferred -> _.delay @resolve, 50, true

    if /\.css$/.test resource
      return resolution if hasStyle resourceRegex
      link = jQuery('<link type="text/css" rel="stylesheet">')
      link.appendTo('head').attr href: server + resource
      return resolution
    else
      fetch = jQuery.ajax
        url: server + resource
        cache: true
        dataType: 'script'
      return fetch.then -> resolution

  scope 'intermine.cdn',

    load: (ident) ->
      {server, tests, resources} = intermine.options.CDN
      conf = resources[ident]
      test = tests[ident]
      load = loader server
      if not conf
        jQuery.Deferred -> @reject "No resource is configured for #{ ident }"
      else if _.isArray(conf)
        parallel conf.map (c) -> load c
      else
        load conf, test


