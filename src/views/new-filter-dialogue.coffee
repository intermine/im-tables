
View = require '../core-view'

ConstraintAdder = require './constraint-adder'

module.exports = class NewFilterDialogue extends Backbone.View

  tagName: "div"

  className: "im-constraint-dialogue modal"

  html: """
    <div class="modal-header">
      <a href="#" class="close pull-right im-close">close</a>
      <h3>Add New Filter</h3>
    </div>
    <div class="modal-body">
    </div>
    <div class="modal-footer">
      <button class="disabled btn btn-primary pull-right im-add-constraint">
          Add Filter
      </button>
      <button class="btn im-close pull-left">
          Cancel
      </button>
    </div>
  """

  initialize: ({@query}) ->
    super
    @listenTo @query, 'change:constraints', @closeDialogue
    @listenTo @query, 'editing-constraint', => # Can we do this on the model?
        @$('.im-add-constraint').removeClass 'disabled'

  events: ->
    'click .im-close': 'closeDialogue'
    'hidden': 'onHidden'
    'click .im-add-constraint': 'addConstraint'

  onHidden: (e) ->
    unless e?.target is @el # ignore bubbled events from sub-dialogues.
      return false
    @remove()

  show: -> @$el.modal().modal('show')

  hide: -> @$el.modal('hide')

  closeDialogue: -> @hide() # TODO - remove when all references checked.

  openDialogue: -> @show() # TODO - remove when all references checked.

  addConstraint: (e) -> # This should probably use promises, even if just for future proofing
    edited = @children.adder.newCon.editConstraint(e)
    @$el.modal('hide') if edited

  render: ->
    # Add to children set so it can be cleaned up on remove.
    @children.adder?.remove()
    @$el.html @html
    @children.adder = a = new ConstraintAdder(@query)
    @$el.find('.modal-body').append a.el
    a.render()
    a.showTree()
    this
