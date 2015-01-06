_ = require 'underscore'
View = require '../../core-view'
Options = require '../../options'
Templates = require '../../templates'

class Tab

  constructor: (@ident, key, @formats = []) ->
    @key = "export.category.#{ key }"

  isFor: (format) -> (@formats.length is 0) or (format.ext in @formats)

TABS = [
  new Tab('dest', 'Destination'),
  new Tab('opts-json', 'JsonFormat', ['json']),
  new Tab('columns', 'Columns'),
  new Tab('rows', 'Rows'),
  new Tab('compression', 'Compression'),
  new Tab('column-headers', 'ColumnHeaders', ['tsv', 'csv']),
  new Tab('preview', 'Preview')
]

module.exports = class TabMenu extends View

  tagName: 'ul'

  RERENDER_EVENT: 'change'

  className: "nav nav-pills nav-stacked im-export-tab-menu"

  template: Templates.template 'export_tab_menu', variable: 'data'

  getData: ->
    tabs = (tab for tab in TABS when tab.isFor @model.get('format'))
    _.extend {tabs}, super

  setTab: (tab) -> => @model.set {tab}

  events: ->
    evt = Options.get 'Events.ActivateTab'
    _.object( ["#{ evt } .im-tab-#{ ident }", (@setTab ident)] \
                                                         for {ident} in TABS )
    
