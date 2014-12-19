_ = require 'underscore'

Model = require './core-model'

Options = require './options'

ICONS = {}

registerIconSet = (name, icons) -> ICONS[name] = _.extend {}, icons

class Icons extends Model

  icon: (key) -> """<i class="#{ @iconClasses key }"></i>"""

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
  sortedASC: "glyphicon-arrow-up"
  sortedDESC: "glyphicon-arrow-down"
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
  Remove: "glyphicon-minus-sign"
  Check: "glyphicon-ok"
  UnCheck: "glyphicon-none"
  CheckUnCheck: "glyphicon-ok-none"
  Add: "glyphicon-plus-sign"
  Move: "glyphicon-move"
  More: "glyphicon-plus-sign"
  Filter: "glyphicon-filter"
  Summary: "glyphicon-eye-open"
  Undo: "glyphicon-refresh"
  Columns: "glyphicon-wrench"
  Collapsed: "glyphicon-chevron-right"
  Expanded: "glyphicon-chevron-down"
  MoveDown: "glyphicon-chevron-down"
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

ICONS.fontawesome =
  Base: 'fa'
  unsorted: "fa-unsorted"
  sortedASC: "fa-sort-up"
  sortedDESC: "fa-sort-down"
  headerIcon: "fa"
  headerIconRemove: "fa-times"
  headerIconHide: "fa-ellipsis-h"
  headerIconReveal: 'fa-arrows-h'
  Yes: "fa-star"
  No: "fa-star-o"
  Table: 'fa-list'
  Script: "fa-cog"
  Export: "fa-cloud-download"
  Remove: "fa-minus-circle"
  Check: "fa-ok"
  UnCheck: "fa-none"
  CheckUnCheck: "fa-none fa-ok"
  Add: "fa-plus"
  Move: "fa-move"
  More: "fa-plus-sign"
  Filter: "fa-filter"
  Summary: "fa-bar-chart-o"
  Undo: "fa-refresh"
  Columns: "fa-wrench"
  Collapsed: "fa-chevron-right"
  Expanded: "fa-chevron-down"
  MoveDown: "fa-chevron-down"
  MoveUp: "fa-chevron-up"
  Toggle: "fa-retweet"
  ExpandCollapse: "fa-chevron-right fa-chevron-down"
  Help: "fa-question-sign"
  Tree: 'fa-sitemap'
  ReverseRef: 'fa-retweet'
  Reorder: "fa-reorder"
  Edit: 'fa-edit'
  ExtraValue: 'fa-database'
  Download: 'fa-file-archive-o'
  ClipBoard: 'fa-paper-clip'
  Composed: 'fa-tags'
  RemoveConstraint: 'fa-times-circle'
  Dismiss: 'fa-times-circle'
  Error: 'fa-warning'
  Lock: 'fa-lock'
  RootClass: 'fa-square'
  Attribute: 'fa-tag'
  ClosedReference: 'fa-plus-square'
  OpenReference: 'fa-plus-square-o'
  tsv: 'fa-list'
  csv: 'fa-list'
  xml: 'fa-xml'
  json: 'fa-json'

module.exports = new Icons
module.exports.Icons = Icons # Export constructor on default instance.
module.exports.registerIconSet = registerIconSet

