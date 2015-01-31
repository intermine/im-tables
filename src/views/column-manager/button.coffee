CoreView = require '../../core-view'
Templates = require '../../templates'
ColumnManger = require 'imtables/views/column-manager'

require '../../messages/columns'

# Simple component that just renders a button which when clicked
# will show the column manager dialogue.
module.exports = class ColumnMangerButton extends CoreView

  # Bootstrap classes and an identifying class.
  className: 'im-column-manager-button'

  # The template for this component.
  template: Templates.template 'column-manager-button'

  # This component receives a query from its parent.
  parameters: ['query']

  events: -> click: @onClick

  # Show the dialogue, if the click was on this very element.
  onClick: (e) -> if /im-open-dialogue/.test e.target.className # Ignore bubbled clicks.
    dialogue = new ColumnManger {@query}
    @renderChild 'dialogue', dialogue
    done = => @removeChild 'dialogue'
    dialogue.show().then done, done
