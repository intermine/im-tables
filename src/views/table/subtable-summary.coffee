CoreView = require '../../core-view'
Messages = require '../../messages'
Templates = require '../../templates'

require '../../messages/subtables'

# This class serves to isolate re-draws to the summary so that they
# don't affect other sub-components.
module.exports = class SubtableSummary extends CoreView

  className: 'im-subtable-summary'
  tagName: 'span'
  template: Templates.template 'table-subtable-summary'

  parameters: ['model']

  modelEvents: -> 'change:contentName': @reRender

  events: -> click: -> @$el.tooltip 'hide'

  postRender: -> @$el.tooltip
    title: (if @model.get('rows').length then Messages.getText('subtables.OpenHint'))
    placement: 'auto right'
