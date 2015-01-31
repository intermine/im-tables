CoreView = require '../../core-view'
Templates = require '../../templates'
ColumnManger = require 'imtables/views/column-manager'

require '../../messages/columns'

# Simple component that just renders a button which when clicked
# will show the column manager dialogue.
module.exports = class ColumnMangerButton extends CoreView

  # This component is a button element.
  tagName: 'button'

  # Bootstrap classes and an identifying class.
  className: 'btn btn-default im-column-manager-button'

  # The template for this component.
  template: Templates.template 'column-manager-button'

  # This component receives a query from its parent.
  parameters: ['query']

  events: -> click: @onClick

  # Show the dialogue, if the click was on this very element.
  onClick: (e) -> if e.target is @el # Ignore bubbled clicks.
    dialogue = new ColumnManger {@query}
    @renderChild 'dialogue', dialogue
    done = => @removeChild 'dialogue'
    dialogue.show().then done, done
