NestedModel = require './core/nested-model'

class Options extends NestedModel

  defaults: ->
    INITIAL_SUMMARY_ROWS: 1000
    NUM_SEPARATOR: ','
    NUM_CHUNK_SIZE: 3
    MAX_PIE_SLICES: 15
    DropdownMax: 20
    DefaultPageSize: 25
    CodeGen:
      Default: 'py'
      Langs: ['py', 'pl', 'java', 'rb', 'js', 'xml']
    ListFreshness: 250 # Number of milliseconds lists requests will be considered fresh for.
    MaxSuggestions: 1000 # Max number of suggestions to fetch and show when editing constraints.
    ListCategorisers: ['organism.name', 'department.company.name']
    PieColors: 'category10'
    TableResults:
      CacheFactor: 10
      RequestLimit: 5000 # Dump the cache rather than request more rows than this
    TableCell:
      PreviewTrigger: 'hover' # one of: hover, click
      HoverDelay: 200 # ms
      IndicateOffHostLinks: true
      ExternalLinkIcons:
        "http://some.host.somewhere": "http://some.host.somewhere/logo.png"
    StylePrefix: 'intermine'
    SuggestionDepth: 4 # When suggestion paths, follow up to this many references.
    Events:
      ActivateTab: 'mouseenter' # or click
    Subtables:
      Initially:
        expanded: false # Set to true to show all subtables by default.
    Facets:
      Initially:
        Open: true # set to false to show them closed, initially.
    Destinations: ['download', 'Galaxy', 'GenomeSpace', 'Drive', 'Dropbox']
    Destination:
      download:
        Enabled: true
      Galaxy:
        Main: "http://main.g2.bx.psu.edu"
        Current: null
        Tool: 'flymine' # The tool we should use to send data to Galaxy
        Save: false
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
        Easing: 'exp' # one of linear, quad, cubic, sin, exp, circle, elastic, back, bounce
        Duration: 500
        DurationShort: 200
    brand: # keys cannot have dots in them, hence the weirdo uris
      "http://www_flymine_org/query/service/":
        name: "FlyMine"
      "http://preview_flymine_org/preview/service/":
        name: "FlyMine-Preview"
      "http://www_mousemine_org/mousemine/service/":
        name: "MouseMine (MGI)"
    preview:
      count: {}
    Formatters: # TODO - install formatters here.
      testmodel: {}
      genomic: {}
    ColumnManager:
      SelectColumn:
        Multi: true
    UndoHistory:
      ShowAllStatesCutOff: 6

# Export the main instance.
module.exports = new Options

# Export the constructor, for testing and such.
module.exports.Options = Options

