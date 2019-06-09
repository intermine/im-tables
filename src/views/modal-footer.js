_ = require 'underscore'
CoreView = require '../core-view'
Templates = require '../templates'

defaultData = ->
  error: null
  exportLink: null
  disabled: false
  disabledReason: null

module.exports = class ModalFooter extends CoreView
  
  tagName: 'div'

  className: 'modal-footer'

  # model properties we read in the template.
  # The error is a blocking error to display to the user, which will disable
  # the main action.
  # The href is used by dialogues that perform export using GETs to URLs that support
  # disposition = attachment, which browsers will perform as a download if this href is
  # used in a link.
  RERENDER_EVENT: 'change:error change:exportLink'

  parameters: ['template', 'actionNames', 'actionIcons']

  getData: -> _.extend defaultData(), @actionNames, @actionIcons, super

  postRender: ->
    @$('[title]').tooltip()

