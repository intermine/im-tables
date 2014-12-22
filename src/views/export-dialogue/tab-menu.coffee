_ = require 'underscore'
View = require '../../core-view'
Templates = require '../../templates'

tabs = [
  {ident: 'format', key: 'export.category.Format'},
  {ident: 'columns', key: 'export.category.Columns'},
  {ident: 'rows', key: 'export.category.Rows'},
  {ident: 'output', key: 'export.category.Output'},
  {ident: 'dest', key: 'export.category.Destination'}
]

module.exports = class TabMenu extends View

  tagName: 'ul'

  RERENDER_EVENT: 'change'

  className: "nav nav-pills nav-stacked im-export-tab-menu"

  template: Templates.template 'export_tab_menu', variable: 'data'

  getData: -> _.extend {tabs}, super

  setTab: (tab) -> => @model.set {tab}

  events: -> _.object( ["click .im-tab-#{ ident }", (@setTab ident)] for {ident} in tabs )
    
