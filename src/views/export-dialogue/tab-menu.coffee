_ = require 'underscore'
View = require '../../core-view'
Options = require '../../options'
Templates = require '../../templates'

class Tab

  constructor: (@ident, key, @formats = [], @groups = null) ->
    @key = "export.category.#{ key }"

  isFor: (format) ->
    return (format.ext in @formats) if @formats.length
    return @groups[format.group] if @groups?
    return true

TABS = [
  new Tab('dest', 'Destination'),
  new Tab('opts-json', 'JsonFormat', ['json']),
  new Tab('columns', 'Columns'),
  new Tab('rows', 'Rows', [], {flat: true, machine: true}),
  new Tab('compression', 'Compression'),
  new Tab('column-headers', 'ColumnHeaders', ['tsv', 'csv']),
  new Tab('preview', 'Preview')
]

module.exports = class TabMenu extends View

  tagName: 'ul'

  RERENDER_EVENT: 'change'

  className: "nav nav-pills nav-stacked im-export-tab-menu"

  template: Templates.template 'export_tab_menu', variable: 'data'

  getTabs: -> (tab for tab in TABS when tab.isFor @model.get('format'))

  getData: ->
    tabs = @getTabs()
    _.extend {tabs}, super

  setTab: (tab) -> => unless @state.get('pinned')
    @model.set {tab}

  setPinned: (tab) -> =>
    if @state.get('pinned') is tab
      @state.set pinned: false
    else
      @state.set pinned: tab

    @model.set tab: tab # for good measure - should have been set by mouseover

  next: ->
    tabs = (t.ident for t in @getTabs())
    current = _.indexOf tabs, @model.get 'tab'
    next = current + 1
    next = 0 if next is tabs.length
    @model.set tab: tabs[next]

  prev: ->
    tabs = (t.ident for t in @getTabs())
    current = _.indexOf tabs, @model.get 'tab'
    prev = if current is 0 then tabs.length - 1 else current - 1
    @model.set tab: tabs[prev]

  events: ->
    evt = Options.get 'Events.ActivateTab'
    events = _.object( ["#{ evt } .im-tab-#{ ident }", (@setTab ident)] \
                                                         for {ident} in TABS )
    if evt is 'mouseenter'
      _.extend events, _.object( ["click .im-tab-#{ ident }", (@setPinned ident)] \
                                                         for {ident} in TABS )
    return events
    
