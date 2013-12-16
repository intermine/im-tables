{getMessage} = require '../messages'

{ActiveConstraint} = require './active-constraint'

class exports.NewConstraint extends ActiveConstraint

  initialize: (q, c) ->
      super q, c
      @$el.addClass "new"
      @buttons[0].text = getMessage "conbuilder.Apply"
      @con.set op: (if @path.isReference() then 'LOOKUP' else '=')

  addIcons: ->

  valueChanged: (value) -> @fillConSummaryLabel _.extend({}, @con, {value: "" + value})

  opChanged: (op) -> @$('.label-op').text op

  removeConstraint: () -> # Nothing to do - just suppress this.

  hideEditForm: (e) ->
      super(e)
      @query.trigger "cancel:add-constraint"
      @remove()

