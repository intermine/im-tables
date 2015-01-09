CoreView = require '../../core-view'
Templates = require '../../templates'

module.exports = class RowSurrogate extends CoreView

  className: 'im-facet-surrogate'

  initialize: ({@above}) -> super

  template: Templates.template 'row_surrogate'

  getData: -> _.extend super, {@above}

  postRender: -> @$el.addClass if above then 'above' else 'below'

  remove: -> @$el.fadeOut 'fast', => super()
