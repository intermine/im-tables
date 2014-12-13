Backbone = require 'backbone'

Options = require './options'

ICONS = {}

class Icons extends Backbone.Model

  icon: (key) -> """<i class="#{ @iconClasses key }"></i>"""

  iconClasses: (key) -> "#{ @get 'Base' } #{ @get key }"

  _loadIconSet: ->
    iconSet = ICONS[Options.get 'icons']
    @set iconSet if iconSet?

  initialize: ->
    @_loadIconSet()
    @listenTo Options, 'change:icons', @_loadIconSet

module.exports = new Icons

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
  Tree: 'glyphicon-plus'
  Download: 'glyphicon-file'
  ClipBoard: 'glyphicon-paper-clip'
  Composed: 'glyphicon-tags'
  RemoveConstraint: 'glyphicon-remove-sign'
  Lock: 'glyphicon-lock'
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
  RootClass: 'fa-stop'
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
  Download: 'fa-file-archive-o'
  ClipBoard: 'fa-paper-clip'
  Composed: 'fa-tags'
  RemoveConstraint: 'fa-times-circle'
  Error: 'fa-warning'
  Lock: 'fa-lock'
  tsv: 'fa-list'
  csv: 'fa-list'
  xml: 'fa-xml'
  json: 'fa-json'
