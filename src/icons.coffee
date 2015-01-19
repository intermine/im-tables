_ = require 'underscore'

Model = require './core-model'

Options = require './options'

ICONS = {}

registerIconSet = (name, icons) -> ICONS[name] = _.extend {}, icons

class Icons extends Model

  icon: (key, size) ->
    sizeCls = if size then @getSize(size) else ''
    """<i class="#{ @iconClasses key } #{ sizeCls }"></i>"""

  getSize: (size) -> @get("size#{ size.toUpperCase() }") ? ''

  iconClasses: (key) -> "#{ @get 'Base' } #{ @get key }"

  _loadIconSet: ->
    iconSet = ICONS[@options.get 'icons']
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
  RootClass: 'glyphicon-stop'
  Yes: "glyphicon-star"
  No: "glyphicon-star-empty"
  Table: 'glyphicon-list'
  Script: "glyphicon-cog"
  Export: "glyphicon-download-alt"
  Error: "glyphicon-warning-sign"
  Info: 'glyphicon-info-sign'
  Warning: "glyphicon-warning-sign"
  Remove: "glyphicon-minus-sign"
  OK: "glyphicon-ok"
  Check: "glyphicon-ok"
  UnCheck: "glyphicon-none"
  CheckUnCheck: "glyphicon-ok-none"
  Add: "glyphicon-plus-sign"
  Move: "glyphicon-move"
  More: "glyphicon-plus-sign"
  Filter: "glyphicon-filter"
  Summary: "glyphicon-eye-open"
  Undo: "glyphicon-refresh"
  Refresh: "glyphicon-refresh"
  Columns: "glyphicon-wrench"
  Collapsed: "glyphicon-chevron-right"
  Expanded: "glyphicon-chevron-down"
  MoveDown: "glyphicon-chevron-down"
  GoBack: "glyphicon-chevron-left"
  GoForward: "glyphicon-chevron-right"
  MoveUp: "glyphicon-chevron-up"
  Toggle: "glyphicon-retweet"
  ExpandCollapse: "glyphicon-chevron-right icon-chevron-down"
  Help: "glyphicon-question-sign"
  ReverseRef: "glyphicon-retweet"
  Reorder: "glyphicon-reorder"
  Edit: 'glyphicon-edit'
  ExtraValue: 'glyphicon-map-marker'
  Tree: 'glyphicon-plus'
  Download: 'glyphicon-file'
  Options: 'glyphicon-tasks'
  ClipBoard: 'glyphicon-paper-clip'
  Composed: 'glyphicon-tags'
  RemoveConstraint: 'glyphicon-remove-sign'
  Dismiss: 'glyphicon-remove-sign'
  Lock: 'glyphicon-lock'
  Attribute: "glyphicon-unchecked"
  tsv: 'glyphicon-list'
  csv: 'glyphicon-list'
  xml: 'glyphicon-xml'
  json: 'glyphicon-json'
  fake: 'glyphicon-bug'

ICONS.fontawesome =
  Base: 'fa'
  unsorted: "fa-unsorted"
  ASC: "fa-sort-up"
  DESC: "fa-sort-down"
  headerIcon: "fa"
  headerIconRemove: "fa-times"
  headerIconHide: "fa-ellipsis-h"
  headerIconReveal: 'fa-arrows-h'
  sizeLG: 'fa-2x'
  Yes: "fa-star"
  No: "fa-star-o"
  Table: 'fa-list'
  Script: "fa-cog"
  Export: "fa-cloud-download"
  Remove: "fa-minus-circle"
  OK: "fa-check"
  Check: "fa-toggle-on"
  UnCheck: "fa-toggle-off"
  CheckUnCheck: "fa-toggle-on fa-toggle-off"
  Add: "fa-plus"
  Move: "fa-move"
  More: "fa-plus-sign"
  Dropbox: 'fa-dropbox'
  Drive: 'fa-google'
  download: 'fa-cloud-download'
  Galaxy: 'fa-cloud-upload'
  GenomeSpace: 'fa-cloud-upload'
  Filter: "fa-filter"
  Summary: "fa-bar-chart-o"
  Undo: "fa-refresh"
  Refresh: "fa-refresh"
  Columns: "fa-wrench"
  Collapsed: "fa-chevron-right"
  Expanded: "fa-chevron-down"
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
  ClipBoard: 'fa-paper-clip'
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
  tsv: 'fa-list'
  csv: 'fa-list'
  xml: 'fa-code'
  json: 'fa-json'
  fake: 'fa-bug'

module.exports = new Icons
module.exports.Icons = Icons # Export constructor on default instance.
module.exports.registerIconSet = registerIconSet

