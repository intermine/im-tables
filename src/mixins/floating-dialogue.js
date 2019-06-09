$ = require 'jquery'

centre = (el) ->
  $body = $ 'body'
  bwidth = $body.width()
  ewidth = el.width()
  el.css
    left: (bwidth - ewidth) / 2
    top: 50

# We override the modal hide/show mechanism because we want this dialogue to
# not have a back-drop and be draggable.
exports._showModal = ->
  el = @$el
  el.modal show: false # we do the showing ourselves in this case.
    .addClass 'im-floating'
    .draggable handle: '.modal-header'
    .show ->
      centre el
      el.animate {opacity: 1}, complete: -> el.addClass 'in'
      
  @listenToOnce @, 'remove', => @$el.draggable 'destroy'

exports._hideModal = ->
  # @$el.modal('hide') does nothing, since we never call show.
  @$el.removeClass('in')
  @onHidden()

