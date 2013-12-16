_ = require 'underscore'

exports.conbuilder =
  Apply: 'Apply'
  ValuePlaceholder: 'David*'
  ExtraPlaceholder: 'Wernham-Hogg'
  ExtraLabel: 'within'
  IsA: 'is a'
  NoValue: 'No value selected. Please enter a value.'
  Duplicate: 'This constraint is already on the query'
  TooManySuggestions: 'We cannot show you all the possible values'

exports.facets =
  DownloadData: 'Save'
  DownloadFormat: 'As'
  More: 'Load more items'
  Include: 'Restrict table to matching rows'
  Exclude: 'Exclude matching rows from table'
  Reset: 'Reset selection'
  ToggleSelection: 'Toggle selection'

exports.cell =
  RelatedItems: "Related item counts:"

exports.columns =
  FindColumnToAdd: 'Add a new Column'
  OrderVerb: 'Add / Remove / Re-Arrange'
  OrderTitle: 'Columns'
  SortVerb: 'Configure'
  SortTitle: 'Sort-Order'
  OnlyColsInView: 'Only show columns in the table:'
  SortingHelpTitle: 'What Columns Can I Sort by?'
  SortingHelpContent: """
    A table can be sorted by any of the attributes of the objects
    which are in the output columns or constrained by a filter, so
    long as they haven't been declared to be optional parts of the
    query. So if you are displaying <span class="label path">Gene > Name</span>
    and <span class="label path">Gene > Exons > Symbol</span>, and also
    <span class="label path">Gene > Proteins > Name</span> if the gene
    has any proteins (ie. the proteins part of the query is optional), then
    you can sort by any of the attributes attached to
    <span class="label path available">Gene</span>
    or <span class="label path available">Gene > Exons</span>,
    whether or not you have selected them for output, but you could not sort by
    any of the attributes of <span class="label path available">Gene > Proteins</span>,
    since these items may not be present in the results.
  """

exports.actions =
  ListNameDuplicate: 'List names must be unique. This name is already taken'
  ListNameEmpty: 'Lists must have names. Please enter one'
  ListNameIllegal: _.template """
    Some characters are not allowed in list names. This name contains the following
    illegal characters: <%- illegals.join(', ') %>. Please remove them.
  """
  ExportTitle: "Download Results"
  ConfigureExport: "Configure Export"
  GetData: "Download Data"
  ExportHelp: "Download file containing results to your computer"
  ExportButton: "Download"
  ExportFormat: "Format"
  Cancel: "Cancel"
  Clear: "Clear"
  Export: "Download"
  'download-file': 'Download File'
  Galaxy: 'Send to Galaxy'
  Genomespace: 'Upload to Genomespace'
  'Destdownload-file': 'File'
  DestGalaxy: 'Galaxy'
  DestGenomespace: 'Genomespace'
  ExportAlt: "Send Data Somewhere Else"
  ExportLong: """
    <span class="hidden-tablet">Download</span>
    File
    <span class="im-only-widescreen">to your Computer</span>
  """
  SendToGalaxy: """
    <span class="hidden-tablet">Send to</span>
    Galaxy
    <span class="im-only-widescreen">for analysis</span>
  """
  SendToGenomespace: """
    <span class="hidden-tablet">Upload to</span>
    <span class="im-only-widescreen">your</span>
    Genomespace
    <span class="im-only-widescreen">account</span>
  """
  MyGalaxy: "Send to your Galaxy"
  ForgetGalaxy: "Clear this galaxy URL"
  GalaxyHelp: "Start a file upload job within Galaxy"
  GalaxyURILabel: "Galaxy Location:"
  GalaxyAlt: "Send to a specific Galaxy"
  SaveGalaxyURL: "Make this my default Galaxy"
  WhatIsGalaxy: "What is Galaxy?"
  WhatIsGalaxyURL: "http://wiki.g2.bx.psu.edu/"
  GalaxyAuthExplanation: """
          If you have already logged into Galaxy with this browser, then the data
          will be sent into your active account. Otherwise it will appear in a 
          temporary anonymous account.
      """
  CopyToClipBoard: 'Copy to clipboard: <CTL>+C, <ENTER>'
  IsPrivateData: """
      This link provides access to data stored in your private lists. In order to do so
      it uses the API access token provided on initialisation. If this is your permanent
      API token you should be as careful of this link as you would of the data is provides
      access to. If this is just a 24 hour access token, then you will need to replace it
      once it becomes invalid.
  """
  LongURI: """
      The normal URI for this query (which includes the full query XML in the 
      parameters) is too long for a GET request. The URI you can see here uses a
      query-id, which has a limited validity. You should not store this URI for long
      term use.
  """
  SendToOtherGalaxy: "Send"
  AllRows: "Whole Result Set"
  SomeRows: "Specific Range"
  WhichRows: "Rows to Export"
  RowsHelp: "Export all rows, or define a range of rows to export."
  AllColumns: "All Current Columns"
  SomeColumns: "Choose Columns"
  CompressResults: "Compress results"
  NoCompression: "No compression"
  GZIPCompression: "GZIP"
  ZIPCompression: "ZIP"
  Copy: 'copy to clip-board'
  ResultsPermaLink: "Perma-link to results"
  ResultsPermaLinkText: "Results URI"
  QueryXML: 'Query XML'
  ResultsPermaLinkTitle: "Get a permanent URL for these results, suitable for your own use"
  ResultsPermaLinkShareTitle: "Get a permanent URL for these results, suitable for sharing with others"
  ColumnsHelp: "Export all columns, or choose specific columns to export."
  WhichColumns: "Columns to Export"
  ResetColumns: "Reset Columns."
  FirstRow: "From"
  LastRow: "To"
  SpreadsheetOptions: "Spreadsheet Options"
  ColumnHeaders: "Include Column Headers"
  PossibleColumns: "You can add any attribute from these nodes without changing your results:"
  ExportedColumns: "Exported Columns (drag to reorder)"
  ChangeColumns: """
          You may add any of the columns in the right hand box by clicking on the
          plus sign. You may remove unwanted columns by clicking on the minus signs
          in the left hand box. Note that while adding these columns will not alter your query,
          if you remove all the attributes from an item, then you <b>may change</b> the results
          you receive.
      """,
  OuterJoinWarning: """
          This query has outer-joined collections. This means that the number of rows in 
          the table is likely to be different from the number of rows in the exported results.
          <b>You are strongly discouraged from specifying specific ranges for export</b>. If
          you do specify a certain range, please check that you did in fact get all the 
          results you wanted.
      """
  IncludedFeatures: "Exportable parts of this Query - <strong>choose at least one</strong>:"
  FastaFeatures: "Features with Sequences in this Query - <strong>select one</strong>:"
  FastaOptions: 'FASTA Specific Options'
  FastaExtension: "Extension (eg: 100/100bp/5kbp/0.5mbp):"
  ExtraAttributes: "Columns to include as extra attributes on each exported record:"
  NoSuitableColumns: """
          There are no columns of a suitable type for this format.
      """
  BEDOptions: "BED Specific Options"
  Gff3Options: 'GFF3 Specific Options'
  ChrPrefix: """
          Prefix "chr" to the chromosome identifier as per UCSC convention (eg: chr2)
      """
  ConfigureExportHelp: 'Configure the export options in these categories'

