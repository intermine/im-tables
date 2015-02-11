CoreView = require '../../core-view'
Templates = require '../../templates'

# This class serves to isolate re-draws to the summary so that they
# don't affect other sub-components.
module.exports = class SubtableSummary extends CoreView

  className: 'im-subtable-summary'
  tagName: 'span'
  template: Templates.template 'table-subtable-summary'

  parameters: ['model']

  modelEvents: -> 'change:contentName': @reRender
