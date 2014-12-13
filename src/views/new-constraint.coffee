_ = require 'underscore'

# Support
Messages = require '../messages'
Icons = require '../icons'

ActiveConstraint = require './active-constraint'

Messages.set
  'conbuilder.Apply': 'Apply'

module.exports = class NewConstraint extends ActiveConstraint

  initialize: ->
    super
    @con.set op: (if @path.isReference() then 'LOOKUP' else '=')

  buttons: ->
    btns = super
    btns[0].key = 'conbuilder.Apply'
    return btns

  render: ->
    super
    @$el.addClass "new"
    this

  valueChanged: (value) -> @fillConSummaryLabel _.extend({}, @con, {value: "" + value})

  opChanged: (op) -> @$('.label-op').text op

  removeConstraint: () -> # Nothing to do - just suppress this.

  hideEditForm: (e) ->
    super(e)
    @query.trigger "cancel:add-constraint"
    @remove()
