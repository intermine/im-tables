do ->

  ICONS = {}
  CSS_ICONS = {}

  CSS_ICONS.glyphicons = {
    unsorted: "icon-resize-vertical"
    sortedASC: "icon-arrow-up"
    sortedDESC: "icon-arrow-down"
    headerIcon: "icon"
    headerIconRemove: "icon-remove"
    headerIconHide: "icon-minus"
    headerIconReveal: 'icon-fullscreen'
  }

  CSS_ICONS.fontawesome = {
      unsorted: "fa-unsorted"
      sortedASC: "fa-sort-up"
      sortedDESC: "fa-sort-down"
      headerIcon: "fa"
      headerIconRemove: "fa-times"
      headerIconHide: "fa-ellipsis-h"
      headerIconReveal: 'fa-arrows-h'
  }

  ICONS.glyphicons = {
    Base: 'icon',
    Yes: "icon-star",
    No: "icon-star-empty",
    Table: 'icon-list',
    Script: "icon-cog",
    Export: "icon-download-alt",
    Remove: "icon-minus-sign",
    Check: "icon-ok",
    UnCheck: "icon-none",
    CheckUnCheck: "icon-ok-none",
    Add: "icon-plus-sign",
    Move: "icon-move",
    More: "icon-plus-sign",
    Filter: "icon-filter",
    Summary: "icon-eye-open",
    Undo: "icon-refresh",
    Columns: "icon-wrench",
    Collapsed: "icon-chevron-right",
    Expanded: "icon-chevron-down",
    MoveDown: "icon-chevron-down",
    MoveUp: "icon-chevron-up",
    Toggle: "icon-retweet",
    ExpandCollapse: "icon-chevron-right icon-chevron-down",
    Help: "icon-question-sign",
    ReverseRef: "icon-retweet",
    Reorder: "icon-reorder",
    Edit: 'icon-edit',
    Tree: 'icon-plus',
    Download: 'icon-file',
    ClipBoard: 'icon-paper-clip',
    Composed: 'icon-tags',
    RemoveConstraint: 'icon-remove-sign',
    Lock: 'icon-lock',
    tsv: 'icon-list',
    csv: 'icon-list',
    xml: 'icon-xml',
    json: 'icon-json',
  }

  ICONS.fontawesome = {
    Base: 'fa',
    Yes: "fa fa-star",
    No: "fa fa-star-o",
    Table: 'fa fa-list',
    Script: "fa fa-cog",
    Export: "fa fa-cloud-download",
    Remove: "fa fa-minus-circle",
    Check: "fa fa-ok",
    UnCheck: "fa fa-none",
    CheckUnCheck: "fa-none fa-ok",
    Add: "fa fa-plus",
    Move: "fa fa-move",
    More: "fa fa-plus-sign",
    Filter: "fa fa-filter",
    Summary: "fa fa-bar-chart-o",
    Undo: "fa fa-refresh",
    Columns: "fa fa-wrench",
    Collapsed: "fa fa-chevron-right",
    Expanded: "fa fa-chevron-down",
    MoveDown: "fa fa-chevron-down",
    MoveUp: "fa fa-chevron-up",
    Toggle: "fa fa-retweet",
    ExpandCollapse: "fa-chevron-right fa-chevron-down",
    Help: "fa fa-question-sign",
    Tree: 'fa fa-sitemap',
    ReverseRef: 'fa fa-retweet',
    Reorder: "fa fa-reorder",
    Edit: 'fa fa-edit',
    Download: 'fa fa-file-archive-o',
    ClipBoard: 'fa fa-paper-clip',
    Composed: 'fa fa-tags',
    RemoveConstraint: 'fa fa-times-circle',
    Lock: 'fa fa-lock',
    tsv: 'fa fa-list',
    csv: 'fa fa-list',
    xml: 'fa fa-xml',
    json: 'fa fa-json'
  }

  scope "intermine.icons", ICONS[intermine.options.Style.icons], true
  scope "intermine.css", CSS_ICONS[intermine.options.Style.icons], true

  intermine.onChangeOption 'Style.icons', (iconStyle) ->
    scope "intermine.icons", ICONS[iconStyle], true
    scope "intermine.css", CSS_ICONS[iconStyle], true
    intermine.cdn.load iconStyle

