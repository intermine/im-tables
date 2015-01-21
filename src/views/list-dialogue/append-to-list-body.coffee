_ = require 'underscore'

CoreView = require '../../core-view' # base
Templates = require '../../templates' # template
Messages = require '../../messages'

# Sub-components
SelectWithLabel = require '../../core/select-with-label'

# This view uses the lists messages bundle.
require '../../messages/lists'

module.exports = class AppendToListBody extends CoreView

  parameters: ['model', 'collection']

  postRender: -> # Render child views.
    @renderListSelector()

  renderListSelector: ->
    selector = new SelectWithLabel
      model: @model
      collection: @collection
      attr: 'target'
      label: 'lists.params.Target'
      optionLabel: 'lists.PossibleAppendTarget'
      helpMessage: 'lists.params.help.Target'
      noOptionsMessage: 'lists.append.NoSuitableLists'
      getProblem: (target) -> not target?.length
    @listenTo selector.state, 'change:error', console.error.bind(console)
    @renderChild 'list-selector', selector
      

