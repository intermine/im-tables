_ = require 'underscore'

Model = require './core-model'

Options = require './options'

ICONS = {}

registerIconSet = (name, icons) -> ICONS[name] = _.extend {}, icons

class Icons extends Model

  icon: (key, size, props = {}) ->
    classes = []
    ps = ("#{ prop }=\"#{ _.escape propVal }\"" for prop, propVal of props \
                                                    when prop isnt 'className')
    classes.push( _.escape props.className ) if 'className' of props
    classes.push @iconClasses key
    classes.push @getSize size if size
    """<i class="#{ classes.join ' ' }" #{ ps.join ' ' }></i>"""

  iconWithProps: (key, props) -> @icon key, null, props

  getSize: (size) -> @get("size#{ size.toUpperCase() }") ? ''

  iconClasses: (key) -> "#{ @get 'Base' } #{ @get key }"

  _loadIconSet: ->
    if iconSet = ICONS[@options.get 'icons']
      @clear silent: true
      @set iconSet if iconSet?

  initialize: (@options = Options) ->
    @_loadIconSet()
    @listenTo @options, 'change:icons', @_loadIconSet

ICONS.glyphicons =
  Base: 'glyphicon'
  unsorted: "glyphicon-resize-vertical"
  ASC: "glyphicon-arrow-up"
  DESC: "glyphicon-arrow-down"
  headerIcon: "icon"
  headerIconRemove: "glyphicon-remove"
  headerIconHide: "glyphicon-minus"
  headerIconReveal: 'glyphicon-fullscreen'
  SortStringASC:   'glyphicon-sort-by-alphabet'
  SortStringDESC:  'glyphicon-sort-by-alphabet-alt'
  SortNumericASC:  'glyphicon-sort-by-order'
  SortNumericDESC: 'glyphicon-sort-by-order-alt'
  RootClass: 'glyphicon-stop'
  Yes: "glyphicon-star"
  No: "glyphicon-star-empty"
  Table: 'glyphicon-list'
  Script: "glyphicon-console"
  Export: "glyphicon-cloud-download"
  Error: "glyphicon-warning-sign"
  Info: 'glyphicon-info-sign'
  Warning: "glyphicon-warning-sign"
  Remove: "glyphicon-minus-sign"
  OK: "glyphicon-ok"
  Cancel: "glyphicon-remove"
  Check: "glyphicon-check"
  UnCheck: "glyphicon-unchecked"
  CheckUnCheck: "glyphicon-ok-none"
  Add: "glyphicon-plus-sign"
  Move: "glyphicon-move"
  More: "glyphicon-plus-sign"
  Filter: "glyphicon-filter"
  Summary: "glyphicon-stats"
  Undo: "glyphicon-refresh"
  Refresh: "glyphicon-refresh"
  Columns: "glyphicon-pause"
  Collapsed: "glyphicon-chevron-right"
  Expanded: "glyphicon-chevron-down"
  CollapsedSection: 'glyphicon-triangle-right'
  ExpandedSection: 'glyphicon-triangle-bottom'
  MoveDown: "glyphicon-chevron-down"
  GoBack: "glyphicon-chevron-left"
  GoForward: "glyphicon-chevron-right"
  MoveUp: "glyphicon-chevron-up"
  Toggle: "glyphicon-random"
  ExpandCollapse: "glyphicon-chevron-right icon-chevron-down"
  Help: "glyphicon-question-sign"
  ReverseRef: "glyphicon-retweet"
  Reorder: "glyphicon-menu-hamburger"
  Edit: 'glyphicon-edit'
  ExtraValue: 'glyphicon-map-marker'
  Tree: 'glyphicon-plus'
  Download: 'glyphicon-save-file'
  download: 'glyphicon-cloud-download'
  Options: 'glyphicon-tasks'
  ClipBoard: 'glyphicon-paperclip'
  Composed: 'glyphicon-tags'
  RemoveConstraint: 'glyphicon-remove-sign'
  Dismiss: 'glyphicon-remove-sign'
  ClosedReference: 'glyphicon-expand'
  OpenReference: 'glyphicon-collapse-down'
  Lock: 'glyphicon-lock'
  Lists: 'glyphicon-list-alt'
  Attribute: "glyphicon-unchecked"
  ExternalLink: 'glyphicon-globe'
  tsv: 'glyphicon-list'
  csv: 'glyphicon-list'
  xml: 'glyphicon-xml'
  json: 'glyphicon-json'
  fake: 'glyphicon-bug'
  Bug: 'glyphicon-bug'
  Rubbish: 'glyphicon-trash'
  RubbishFull: 'glyphicon-trash'
  Joins: 'glyphicon-link'
  Mail: 'glyphicon-envelope'

ICONS.fontawesome =
  Base: 'fa'
  unsorted: "fa-unsorted"
  ASC: "fa-sort-up"
  DESC: "fa-sort-down"
  SortStringASC: 'fa-sort-alpha-asc'
  SortStringDESC: 'fa-sort-alpha-desc'
  SortNumericASC: 'fa-sort-numeric-asc'
  SortNumericDESC: 'fa-sort-numeric-desc'
  headerIcon: "fa"
  headerIconRemove: "fa-times"
  headerIconHide: "fa-ellipsis-h"
  headerIconReveal: 'fa-arrows-h'
  sizeLG: 'fa-2x'
  Yes: "fa-star"
  No: "fa-star-o"
  Table: 'fa-list'
  EmptyTable: 'fa-table'
  Script: "fa-file-code-o"
  Export: "fa-cloud-download"
  Remove: "fa-minus-circle"
  OK: "fa-check"
  Cancel: "fa-remove"
  Check: "fa-toggle-on"
  UnCheck: "fa-toggle-off"
  CheckUnCheck: "fa-toggle-on fa-toggle-off"
  Add: "fa-plus"
  Move: "fa-arrows"
  More: "fa-plus"
  Dropbox: 'fa-dropbox'
  Drive: 'fa-google'
  download: 'fa-cloud-download'
  Galaxy: 'fa-cloud-upload'
  Filter: "fa-filter"
  Summary: "fa-bar-chart-o"
  Undo: "fa-undo"
  Refresh: "fa-refresh"
  Columns: "fa-columns"
  Collapsed: "fa-chevron-right"
  Expanded: "fa-chevron-down"
  CollapsedSection: 'fa-caret-right'
  ExpandedSection: 'fa-caret-down'
  MoveDown: "fa-chevron-down"
  GoBack: "fa-chevron-left"
  GoForward: "fa-chevron-right"
  MoveUp: "fa-chevron-up"
  Toggle: "fa-retweet"
  ExpandCollapse: "fa-chevron-right fa-chevron-down"
  Help: "fa-question-circle"
  Tree: 'fa-sitemap'
  ReverseRef: 'fa-retweet'
  Reorder: "fa-reorder"
  Options: 'fa-tasks'
  Edit: 'fa-edit'
  ExtraValue: 'fa-database'
  Download: 'fa-file-archive-o'
  ClipBoard: 'fa-paperclip'
  Composed: 'fa-tags'
  RemoveConstraint: 'fa-times-circle'
  Dismiss: 'fa-times-circle'
  Error: 'fa-warning'
  Info: 'fa-info-circle'
  Warning: 'fa-warning'
  Lock: 'fa-lock'
  RootClass: 'fa-square'
  Attribute: 'fa-tag'
  ClosedReference: 'fa-plus-square'
  OpenReference: 'fa-plus-square-o'
  CodeFile: 'fa-file-code-o'
  Rubbish: 'fa-trash-o'
  RubbishFull: 'fa-trash'
  Joins: 'fa-share-alt'
  ExternalLink: 'fa-globe'
  Lists: 'fa-cloud-upload'
  tsv: 'fa-file-excel-o'
  csv: 'fa-file-excel-o'
  xml: 'fa-code'
  json: 'fa-json'
  fake: 'fa-bug'
  Bug: 'fa-bug'
  Mail: 'fa-envelope'

module.exports = new Icons
module.exports.Icons = Icons # Export constructor on default instance.
module.exports.registerIconSet = registerIconSet

# Get all registered icon names.
module.exports.names = ->
  listsOfNames = (_.keys(s) for n, s of ICONS)
  _.union.apply null, listsOfNames
