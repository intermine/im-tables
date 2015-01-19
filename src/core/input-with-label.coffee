_ = require 'underscore'
CoreView = require '../core-view'
Templates = require '../templates'

# One word of caution - you should never inject the state into
# this component (except for observation). If two components share
# the same state object, they will probably collide on the validation
# state. The only valid reason to do such a thing would be if two
# such or similar components write to the same value.
module.exports = class InputWithLabel extends CoreView

  className: 'form-group'

  template: Templates.template 'input-with-label'

  parameters: ['attr', 'placeholder', 'label']

  optionalParameters: ['getProblem', 'helpMessage']

  # A function that takes the model value and returns a Problem if there is one
  # A Problem is any truthy value. For simple cases `true` will do just fine,
  # but the following fields are recognised:
  #   - level: 'warning' or 'error' - default = 'error'
  #   - message: A Messages key to replace the text in the help block.
  getProblem: (value) -> null

  # Nothing by default - provide one to give help if there is a problem. Also,
  # problems may define their own help (see ::getProblem).
  helpMessage: null

  initialize: ->
    super
    @setValidity()

  setValidity: -> @state.set problem: @getProblem @model.get @attr

  getData: -> _.extend @getBaseData(),
    value: @model.get(@attr)
    label: @label
    placeholder: @placeholder
    helpMessage: @helpMessage
    hasProblem: @state.get('problem')

  postRender: ->
    @$el.addClass @className # in case we were renderedAt
    @onChangeValidity()

  events: ->
    'keyup input': 'setModelValue'

  stateEvents:  -> 'change:problem': @onChangeValidity

  modelEvents: ->
    e = {}
    e["change:#{ @attr }"] = @onChangeValue
    return e

  onChangeValue: ->
    @setValidity()
    @setDOMValue()

  onChangeValidity: ->
    problem = @state.get 'problem'
    help = @$ '.help-block'
    if problem
      @$el.toggleClass 'has-warning', (problem.level is 'warning')
      @$el.toggleClass 'has-error', (problem.level isnt 'warning')
      help.text(Messages.getText(problem.message)) if problem.message?
      help.slideDown()
    else
      @$el.removeClass 'has-warning has-error'
      help.slideUp()

  setModelValue: (e) -> @model.set @attr, e.target.value

  setDOMValue: ->
    $input = @$ 'input'
    domValue = $input.val()
    modelValue = @model.get @attr
    # We check that this is necessary to avoid futzing about with the cursor.
    if modelValue isnt domValue
      console.log 'setting DOM value'
      $input.val modelValue

