_ = require 'underscore'

Model = require './core-model'

mergeOldAndNew = (oldValue, newValue) ->
  _.extend {}, (if _.isObject oldValue then oldValue else {}), newValue

# Supports nested keys.
class Options extends Model

  _triggerChangeRecursively: (ns, obj) ->
    for k, v of obj
      thisKey = "#{ ns }.#{ k }"
      if _.isObject v
        @_triggerChangeRecursively thisKey, v
      else
        @trigger "change:#{ thisKey }", @, @get(thisKey)

  get: (key) -> # Support nested keys - TODO, write tests
    if /\w+\.\w+/.test key
      [head, tail...] = key.split /\./
      # Safely get properties.
      tail.reduce ((m, k) -> m and m[k]), super head
    else
      super key

  set: (key, value) -> # Support nested keys
    oldValue = @get key
    if _.isString(key) # Handle calls as (String, Object) ->
      if not oldValue?
        super key, value
        newValue = @get key
        @_triggerChangeRecursively key, newValue
      else if _.isObject value
        newValue = mergeOldAndNew oldValue, value
        super key, newValue
        # only keys in value have changed
        @_triggerChangeRecursively key, value
      else # Simple value - overwrite.
        super key, value
        if oldValue? and _.isObject oldValue
          @_triggerChangeRecursively key, oldValue
    else # Handle calls as (Object) ->, but gnore the options object.
      for k, v of key
        @set k, v

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
    Galaxy:
      Main: "http://main.g2.bx.psu.edu"
      Current: null
      Tool: 'flymine' # The tool we should use to send data to Galaxy
      Enable: true # Set this to false to disable this export destination
    GenomeSpace:
      Upload: "https://gsui.genomespace.org/jsui/upload/loadUrlToGenomespace.html"
      Enable: true # Set this to false to disable this export destination
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

# Export the main instance.
module.exports = new Options

# Export the constructor, for testing and such.
module.exports.Options = Options

