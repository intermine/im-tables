_ = require 'underscore'
CoreView = require '../core-view'
Templates = require '../templates'

# Simple component that just renders a button which when clicked
# will show the a query dialogue, specified by the Dialogue property,
# which should be a constructor or a factory accepting a single argument
# of the form: {query :: Query}
module.exports = class QueryDialogueButton extends CoreView

  # Implementing classes must specifiy this property.
  Dialogue: -> throw new Error 'Not implemented'

  # Implementing classes should specify a message name, as a property or method.
  longLabel: -> throw new Error 'Not implemented'
  shortLabel: -> throw new Error 'Not implemented'
  icon: -> throw new Error 'Not implemented'

  # The template for this component.
  template: Templates.template 'modal-dialogue-opener'

  labels: ->
    ICON: (_.result @, 'icon')
    LONG: (_.result @, 'longLabel')
    SHORT: (_.result @, 'shortLabel')

  # This component receives a query from its parent.
  parameters: ['query']

  initState: -> @state.set disabled: false

  events: -> click: @onClick

  # Show the dialogue, if the click was on this very element.
  onClick: (e) -> unless (@state.get 'disabled')
    dialogue = new @Dialogue {@query}
    @renderChild 'dialogue', dialogue
    @state.set disabled: true
    done = =>
      @removeChild 'dialogue'
      _.defer => @state.set disabled: false
    dialogue.show().then done, done

