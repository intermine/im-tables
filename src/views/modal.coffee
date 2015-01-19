{Promise} = require 'es6-promise'
_ = require 'underscore'
View = require '../core-view'
Messages = require '../messages'
Templates = require '../templates'

modalTemplate = Templates.template 'modal_base'

ModalFooter = require './modal-footer'

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

  Footer: ModalFooter

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
    @renderChild 'footer', (new this.Footer opts), @$ '.modal-content'

  postRender: ->
    @renderFooter()

  onHidden: (e) ->
    if e? and e.target isnt @el # ignore bubbled events from sub-dialogues.
      return false
    @resolve 'dismiss' # User has dismissed this modal.
    @shown = false
    @remove()

  remove: ->
    # While this looks dangerous (since rejection triggers removal), it in fact can
    # cause no more than one nested call since rejection is a no-op if the promise is
    # already resolved or rejected.
    @reject new Error 'unresolved before removal'

    # Allow removal and hiding to go together.
    # note that we return here to avoid infinite recursion, since hiding triggers removal.
    return @_hideModal() if @shown

    super()

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
      @_showModal()
      @trigger 'shown', @shown = true
    catch e
      @reject e

    return p

  # Actually show the modal dialogue. Override to customise.
  # This is a protected method - if you are not a modal yourself, do not call this method.
  _showModal: -> @$el.modal().modal 'show'

  # Actually hide the modal dialogue. Override to customise.
  # This is a protected method - if you are not a modal yourself, do not call this method.
  _hideModal: -> @$el.modal 'hide'
