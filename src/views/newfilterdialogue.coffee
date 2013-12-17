Backbone = require 'backbone'

{ConstraintAdder} = require './constraint-adder'

class exports.NewFilterDialogue extends Backbone.View
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

    initialize: (@query) ->
        @query.on 'change:constraints', @closeDialogue, @
        @query.on 'editing-constraint', () =>
            @$('.im-add-constraint').removeClass 'disabled'

    events:
        'click .im-close': 'closeDialogue'
        'hidden': 'onHidden'
        'click .im-add-constraint': 'addConstraint'

    onHidden: (e) ->
      unless e and e.target is @el
        return false
      @remove()

    closeDialogue: (e) -> @$el.modal('hide')

    openDialogue: () -> @$el.modal().modal('show')

    addConstraint: (e) ->
        edited = @conAdder.newCon.editConstraint(e)
        @$el.modal('hide') if edited

    render: () ->
        @$el.append @html
        @conAdder = new ConstraintAdder(@query)
        @$el.find('.modal-body').append @conAdder.render().el
        @conAdder.showTree()
        this
