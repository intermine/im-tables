Messages = require '../messages'

ActiveConstraint = require './active-constraint'

Messages.set
  'conbuilder.Apply': 'Apply'

module.exports = class NewConstraint extends ActiveConstraint

  initialize: ->
    super
    @model.set
      new: true
      op: (if @model.get('path').isAttribute() then '=' else 'LOOKUP')
    @state.set
      editing: true

  render: ->
    super
    @$el.addClass "im-new"
    this
