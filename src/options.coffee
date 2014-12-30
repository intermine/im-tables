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

  get: (key) -> # Support nested keys
    if _.isArray(key)
      [head, tail...] = key
      # Safely get properties.
      tail.reduce ((m, k) -> m and m[k]), super head
    else if /\w+\.\w+/.test key
      @get key.split /\./
    else
      super key

  setSection = (m, k) ->
    v = m[k]
    if not _.isObject(v) # mid-sections must be indexable objects (including arrays)
      m[k] = {}
    else
      v

  _triggerPathChange: (key) ->
    path = []
    for section in key
      path.push section
      @trigger "change:#{ path.join('.') }", this, @get path

  _triggerUnsetPath: (path, prev) ->
    if _.isObject(prev)
      for k, v of prev
        @_triggerUnsetPath path.concat([k]), v
    else
      @trigger "change:#{ path.join('.') }"

  # See tests for specification.
  set: (key, value) -> # Support nested keys
    throw new Error("No key") unless key?
    if _.isArray(key) # Handle key paths.
      # Recurse into subkeys.
      if _.isObject(value) and not _.isArray(value)
        for k, v of value
          @set key.concat([k]), v
        return

      [head, mid..., end] = key
      headVal = @get head
      # Ensure the root is an object.
      if headVal and (not _.isObject headVal) # primitive - unset it first.
        @unset head
      # Merge or create new path to value
      root = (headVal ? {})
      currentValue = mid.reduce setSection, root
      prev = currentValue[end]
      currentValue[end] = value
      super head, root
      @_triggerPathChange key
      if prev? and not value?
        @_triggerUnsetPath key, prev
    else if _.isString(key) # Handle calls as (String, Object) ->
      if /\w+\.\w+/.test key
        @set (key.split /\./), value
      else if _.isObject(value) and not _.isArray(value)
        @set [key], value
      else
        super # Handle simple key-value pairs, including unset.
    else # Handle calls as (Object) ->, but ignore the options object.
      for k, v of key
        @set k, v

  defaults: ->
    INITIAL_SUMMARY_ROWS: 1000
    NUM_SEPARATOR: ','
    NUM_CHUNK_SIZE: 3
    MAX_PIE_SLICES: 15
    DropdownMax: 20
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
    SuggestionDepth: 4 # When suggestion paths, follow up to this many references.
    Destinations: ['download', 'Galaxy', 'GenomeSpace', 'Drive', 'Dropbox']
    Destination:
      download:
        Enabled: true
      Galaxy:
        Main: "http://main.g2.bx.psu.edu"
        Current: null
        Tool: 'flymine' # The tool we should use to send data to Galaxy
        Enabled: true # Set this to false to disable this export destination
      GenomeSpace:
        Upload: "https://gsui.genomespace.org/jsui/upload/loadUrlToGenomespace.html"
        Enabled: true # Set this to false to disable this export destination
      Drive:
        Library: 'https://apis.google.com/js/client.js'
        Enabled: false # To enable, set this to true and provide auth.drive
      Dropbox:
        Library: 'https://www.dropbox.com/static/api/2/dropins.js'
        Enabled: false # To enable, set this to true and provide auth.dropbox
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

