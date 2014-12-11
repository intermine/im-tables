Backbone = require 'backbone'
_ = require 'underscore'

# Supports nested keys.
class Options extends Backbone.Model

  get: (key) -> # Support nested keys - TODO, write tests
    if /\w+\.\w+/.test key
      [head, tail...] = key.split /\./
      tail.reduce ((m, k) -> m[k]), super head
    else
      super key

  set: (key, value) -> # Support nested keys
    oldValue = @get key
    if not value
      super key, value
      if _.isObject oldValue
        for k, v of oldValue
          @trigger "change:#{ key }.#{ k }", @
    else if not value? and typeof key isnt 'string'
      for k, v of key
        @set k, v
    else if typeof value isnt 'string' # object value - trigger change sub-events
      newValue = _.extend {}, (if _.isObject oldValue then oldValue else {}), value
      super key, newValue
      for k, v of value
        @trigger "change:#{ key }.#{ k }", @, value[v]
    else
      super key

  defaults: ->
    INITIAL_SUMMARY_ROWS: 1000
    NUM_SEPARATOR: ','
    NUM_CHUNK_SIZE: 3
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
    GalaxyTool: 'flymine' # The tool we should use to send data to Galaxy
    GenomeSpaceUpload: "https://gsui.genomespace.org/jsui/upload/loadUrlToGenomespace.html"
    EnableGalaxy: true # Set this to false to disable this export destination
    EnableGenomespace: true # Set this to false to disable this export destination
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
    icons: 'fontawesome'
    D3:
      Transition:
        Easing: 'elastic'
        Duration: 750
    brand:
      "http://www.flymine.org": "FlyMine"
      "http://preview.flymine.org": "FlyMine-Preview"
      "http://www.mousemine.org": "MouseMine (MGI)"
    preview:
      count: {}

module.exports = new Options

