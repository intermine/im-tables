_ = require 'underscore'
Icons = require '../icons'
Messages = require '../messages'
ItemView = require './item-view'
ExportDialogue = require './export-dialogue'

class module.exports.ExportManager extends ItemView

  tagName: 'li'

  className: 'im-data-export'

  initialize: (@states) -> super()

  template: _.template """
      <a class="btn im-open-dialogue">
        <i class="#{ Icons.Export }"></i>
        <span class="visible-desktop">
          #{ Messages.getMessage('exports.actions.ExportButton') }
        </span>
      </a>
  """

  events: -> 'click .im-open-dialogue': 'openDialogue'

  openDialogue: ->
    @dialogue?.remove()
    @dialogue = new ExportDialogue @states.currentQuery
    @$el.append @dialogue.render().el
    @dialogue.show()
