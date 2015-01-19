# We override the modal hide/show mechanism because we want this dialogue to
# not have a back-drop and be draggable.
exports._showModal = ->
  @$el.modal show: false # we do the showing ourselves in this case.
  @$el.show => @$el.addClass('in').draggable handle: '.modal-header'
  @listenToOnce @, 'remove', => @$el.draggable 'destroy'

exports._hideModal = ->
  # @$el.modal('hide') does nothing, since we never call show.
  @$el.removeClass('in')
  @onHidden()

