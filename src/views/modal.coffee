{Promise} = require 'es6-promise'
_ = require 'underscore'
View = require '../core-view'
Messages = require '../messages'
Templates = require '../templates'

modalTemplate = Templates.template 'modal_base'

class ModalFooter extends View
  
  tagName: 'div'

  className: 'modal-footer'

  # model properties we read in the template.
  # The error is a blocking error to display to the user, which will disable
  # the main action.
  # The href is used by dialogues that perform export using GETs to URLs that support
  # disposition = attachment, which browsers will perform as a download if this href is
  # used in a link.
  RERENDER_EVENT: 'change:error change:exportLink'

  initialize: ({@template, @actionNames, @actionIcons}) ->
    super

  getData: -> _.extend {error: null, exportLink: null}, @actionNames, @actionIcons, super

module.exports = class Modal extends View

  className: -> 'modal fade'

  initialize: ->
    super
    # Create a promise and capture its resolution controls.
    @_promise = new Promise((@resolve, @reject) =>)
    @listenTo @state, 'change', @renderFooter

  resolve: -> throw new Error 'resolved before initialisation'

  reject: -> throw new Error 'rejected before initialisation'

  dismissError: -> # remove the error, gracefully.
    @$('.modal-footer .alert').slideUp 250, => @state.set error: null

  events: ->
    'click .modal-footer .alert .dismiss': 'dismissError' # Dismiss error
    'click .modal-footer .btn-cancel': 'hide' # Establish a convention for closing modals.
    'click .modal-footer > button.btn-primary': 'act' # Establish a convention for acting.
    'hidden.bs.modal': 'onHidden' # Can be caused by user clicking off the modal.
    'click .close': 'hide' # Establish a convention for closing modals.

  promise: -> @_promise

  hide: -> @resolve 'dismiss'

  # Override this to make the modal *do* something.
  act: -> throw new Error 'Not implemented.'

  primaryIcon: -> null

  renderFooter: ->
    return unless @rendered
    dismissAction = _.result @, 'dismissAction'
    primaryAction = _.result @, 'primaryAction'
    primaryIcon = _.result @, 'primaryIcon'
    opts =
      template: @footer
      model: @state
      actionNames: {dismissAction, primaryAction}
      actionIcons: {primaryIcon}
    @renderChild 'footer', (new ModalFooter opts), @$ '.modal-content'

  postRender: ->
    @renderFooter()

  onHidden: (e) ->
    if e? and e.target isnt @el # ignore bubbled events from sub-dialogues.
      return false
    @resolve 'dismiss' # User has dismissed this modal.
    @shown = false
    @remove()

  remove: ->
    return @$el.modal 'hide' if @shown # Allow removal and hiding to go together.
    @reject new Error 'unresolved before removal' # no-op if already resolved or rejected.
    super

  # Override these to provide better text. Can be function or value. You should
  # always override title and primaryAction
  title: -> Messages.getText 'modal.DefaultTitle'
  dismissAction: -> Messages.getText 'modal.Dismiss'
  primaryAction: -> Messages.getText 'modal.OK'
  modalSize: ->

  # Override to provide the modal body. Not required if loading child components.
  body: ->

  # Override to customise the footer.
  footer: Templates.templateFromParts ['modal_error', 'modal_footer']

  # Use this to make use of the default modal structure.
  template: (data) ->
    title = _.result @, 'title'
    body = @body data
    modalSize = "modal-#{ _.result @, 'modalSize' }"
    modalTemplate {title, body, modalSize}

  shown: false

  # Can be called multiple times, and called on re-render.
  # @return [Promise<String>] A promise resolved with the name of an action to take.
  show: ->
    p = @promise()
    p.then (=> @remove()), (=> @remove())

    try
      @$el.modal().modal 'show'
      @trigger 'shown', @shown = true
    catch e
      @reject e

    return p

