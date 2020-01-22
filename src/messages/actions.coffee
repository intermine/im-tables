module.exports =
  'export.Export': 'Export'
  'export.ExportQuery': 'Export'
  'export.DialogueTitle': 'Export'
  'export.category.Format': "<%= format.EXT %> Format",
  'export.category.Columns': "<%= columns %> Columns",
  'export.category.Preview': "Preview",
  'export.preview.Limit': 'Preview is limited to at most 3 results.',
  'export.heading.Columns': "Columns",
  'export.category.Rows': """
    <% if (rowCount === max) { %>
      All
    <% } else { %>
      <%= rowCount %> of <%= max %>
    <% } %>
    Rows
  """,
  'export.category.Compression': """
    <% if (compression) { %>
      <%= compression.toUpperCase() %>
    <% } else { %>
      No
    <% } %> Compression
  """
  'export.category.Options': "Options",
  'export.category.JsonFormat': """
    As <%= (jsonFormat === 'objects') ? 'Objects' : 'Rows' %>
  """
  'export.category.FastaFormat': 'FASTA options'
  'export.category.ColumnHeaders': """
    <% if (headers) { %>
      <%= {friendly: 'Formatted', path: 'Raw'}[headerType] %>
    <% } else { %>
      No
    <% } %>
    Column Headers
  """
  'export.category.Destination': """
    <% if (dest === 'download') { %>
      Download <%= format.EXT %> file
    <% } else { %>
      Send <%= format.EXT %> to <%= dest %>
    <% } %>
  """
  'export.galaxy.name': [
    '<% if (orgs.length === 1) { %><%= orgs[0] %> <% } %>',
    '<%= cls %> data',
    '<% if (branding) { %> from <%= branding.name %><% } %>'
  ].join('')
  'export.galaxy.info': """
    <%= query.root %> data from <%= query.service.root %>.
    Uploaded from <%= currentLocation %>.
    <% if (lists.length) { %>source: <%= lists.join(', ') %><% } %>
    <% if (orgs.length)  { %>organisms: <%= orgs.join(', ') %><% } %>
  """
  'export.format.description.TSV': 'A flat file format suitable for spreadsheet programmes'
  'export.format.name.TSV': 'Tab separated values.'
  'export.format.description.CSV': 'A flat file format, suitable for spreadsheet programmes'
  'export.format.name.CSV': 'Comma separated values.'
  'export.format.description.XML': 'A text format suitable for machine processing.'
  'export.format.name.XML': 'XML'
  'export.format.name.JSON': 'JSON'
  'export.format.description.JSON': """
    A text format suitable for machine processing.
  """
  'export.format.name.FASTA': 'FASTA sequence.'
  'export.format.description.FASTA': 'FASTA output for sequence data.'
  'export.format.name.GFF3': 'GFF3 features.'
  'export.format.description.GFF3': 'GFF3 output for sequence features.'
  'export.format.name.BED': 'BED locations.'
  'export.format.description.BED': 'BED output for sequence feature locations.'
  'export.format.name.FAKE': 'Fake'
  'export.format.description.FAKE': """
    Fake format for testing. Should only appear if the
    query has departments in the view.
  """
  'export.format.name.FAKE_2': 'Also Fake'
  'export.format.description.FAKE_2': """
    Fake format for testing. Should only appear if the
    query has companies in the view.
  """
  'export.param.Size': 'Size: <%= size %>'
  'export.param.Format': 'Format'
  'export.param.Start': 'Offset: <%= start %>'
  'export.param.Destination': 'Destination'
  'export.param.Name': 'File name'
  'export.help.AdditionalCols': """
    You can add any attributes of objects which are already
    in the query.
  """
  'rows.All': 'No limit'
  'export.cloud.FileLocation': """
    Upload to <%- cloud %> successful. Your file is available at:
  """
  'export.UseCompression': 'Compress results'
  'export.UseGZIP': 'Use GZIP compression (produces a .gzip archive)'
  'export.UseZIP': 'Use Zip compression (produces a .zip archive)'
  'export.AddHeaders': 'Add column headers'
  'export.json.Rows': """
    Return results as rows - each row is an Array of JSON values, e.g.:
  """
  'export.SetTablePage': 'Select rows in table'
  'export.ResetRowSelection': 'Select all rows'
  'export.json.RowsExample': '["eve", "2R", 5866824, 5868300]'
  'export.json.ObjExample': """
    {
      "class": "Gene",
      "symbol": "eve",
      "chromosomeLocation": {
        "class": "ChromosomeLocation",
        "start": 5866824,
        "end": 5868300
        "locatedOn": {
          "class": "Chromosome",
          "primaryIdentifier": "2R"
        }
      }
    }
  """
  'export.json.Objects': """
    Return results as objects - each result is a nested graph of
    data, e.g.:
  """
  'export.json.ObjWarning': """
    Please note that it is not recommended to set the size parameters
    when requesting object results, since the size of the result
    set, and the position of the offsets will differ when multiple
    rows are replaced by a single object with a collection.
  """
  'export.ff.FriendlyHeaders': 'Human readable headers (eg. "Gene > Organism Name")'
  'export.ff.PathHeaders': 'Raw path headers (eg. "Gene.organism.shortName)'
  'export.error.NoColumnsSelected': 'No columns selected'
  'export.error.OffsetOutOfBounds': """
    The offset is greater than the total number of results.
  """
  ListNameDuplicate: 'List names must be unique. This name is already taken',
  ListNameEmpty: 'Lists must have names. Please enter one',
  ListNameIllegal: """
    Some characters are not allowed in list names. This name contains the following
    illegal characters: <%- illegals.join(', ') %>. Please remove them.
  """
  ExportTitle: "Download results for <%= name || 'query' %>",
  ConfigureExport: "Configure Export",
  GetData: "Download Data",
  ExportHelp: "Download file containing results to your computer",
  ExportButton: "Download",
  'download-file': 'Download File',
  download: 'Download file'
  Galaxy: 'Send to Galaxy',
  Drive: 'Save to Google Drive'
  Dropbox: 'Save to Dropbox'
  'Destdownload-file': 'File',
  DestGalaxy: 'Galaxy',
  ExportAlt: "Send Data Somewhere Else",
  ExportLong: """
    <span class="hidden-tablet">Download</span>
    File
    <span class="im-only-widescreen">to your Computer</span>
  """,
  SendToGalaxy: """
    <span class="hidden-tablet">Send to</span>
    Galaxy
    <span class="im-only-widescreen">for analysis</span>
  """,
  MyGalaxy: "Send to your Galaxy",
  ForgetGalaxy: "Clear this galaxy URL",
  GalaxyHelp: "Start a file upload job within Galaxy",
  GalaxyURILabel: "Galaxy Location:",
  GalaxyAlt: "Send to a specific Galaxy",
  SaveGalaxyURL: "Make this my default Galaxy",
  WhatIsGalaxy: "What is Galaxy?",
  WhatIsGalaxyURL: "https://galaxyproject.org/tutorials/g101/",
  GalaxyAuthExplanation: """
          If you have already logged into Galaxy with this browser, then the data
          will be sent into your active account. Otherwise it will appear in a 
          temporary anonymous account.
      """,
  CopyToClipBoard: 'Copy to clipboard: <CTL>+C, <ENTER>',
  IsPrivateData: """
      This link provides access to data stored in your private lists. In order to do so
      it uses the API access token provided on initialisation. If this is your permanent
      API token you should be as careful of this link as you would of the data is provides
      access to. If this is just a 24 hour access token, then you will need to replace it
      once it becomes invalid.
  """,
  LongURI: """
      The normal URI for this query (which includes the full query XML in the 
      parameters) is too long for a GET request. The URI you can see here uses a
      query-id, which has a limited validity. You should not store this URI for long
      term use.
  """,
  SendToOtherGalaxy: "Send",
  AllRows: "Whole Result Set"
  SomeRows: "Specific Range",
  WhichRows: "Rows to Export",
  RowsHelp: "Export all rows, or define a range of rows to export.",
  AllColumns: "All Current Columns",
  SomeColumns: "Choose Columns",
  CompressResults: "Compress results",
  NoCompression: "No compression",
  GZIPCompression: "GZIP",
  ZIPCompression: "ZIP",
  Copy: 'copy to clip-board'
  ResultsPermaLink: "Perma-link to results",
  ResultsPermaLinkText: "Results URI",
  QueryXML: 'Query XML',
  ResultsPermaLinkTitle: "Get a permanent URL for these results, suitable for your own use",
  ResultsPermaLinkShareTitle: "Get a permanent URL for these results, suitable for sharing with others",
  ColumnsHelp: "Export all columns, or choose specific columns to export.",
  WhichColumns: "Columns to Export",
  ResetColumns: "Reset Columns.",
  FirstRow: "From",
  LastRow: "To",
  SpreadsheetOptions: "Spreadsheet Options",
  ColumnHeaders: "Include Column Headers",
  PossibleColumns: "You can add any attribute from these nodes without changing your results:",
  ExportedColumns: "Exported Columns (drag to reorder)",
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
  'largetable.ok': 'Set page size to <%- size %>'
  'largetable.abort': 'Cancel'
  'largetable.appeal': """
    You have requested a very large table size (<%= size %> rows per page). Your
    browser may struggle to render such a large table,
    and the page could become unresponsive. In any case,
    will be very difficult for you to read the whole table
    in the page. We suggest the following alternatives:
  """

