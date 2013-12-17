{getMessageSet, getMessage} = require '../messages'
css = require '../css'

InterMineView      = require './intermine-view'
{ActiveConstraint} = require './active-constraint'

class exports.FilterManager extends Constraints

    className: "im-filter-manager modal"
    tagName: "div"

    initialize: (@query) ->
        @query.on 'change:constraints', () => @hideModal()

    html: """
        <div class="modal-header">
            <a class="close im-closer">close</a>
            <h3>#{ getMessage 'filters.Heading' }</h3>
        </div>
        <div class="modal-body">
            <div class="#{ css.FilterBoxClass }">
                <p class="well-help"></p>
                <ul></ul>
            </div>
            <button class="btn im-closer im-define-new-filter">
                #{ getMessage 'filters.DefineNew' }
            </button>
        </div>
    """

    events:
        'hidden': 'remove'
        'click .icon-remove-sign': 'hideModal'
        'click .im-closer': 'hideModal'
        'click .im-define-new-filter': 'addNewFilter'

    addNewFilter: (e) -> @query.trigger 'add-filter-dialogue:please'

    hideModal: (e) ->
        @$el.modal 'hide'
        # Horrible, horrible hackity hack, making kittens cry.
        $('.modal-backdrop').trigger 'click'

    showModal: -> @$el.modal().modal 'show'

    render: ->
        @$el.append @html
        cons = @getConstraints()
        msgs = getMessageSet 'filters'

        @$('.well-help').append if cons.length then msgs.EditOrRemove else msgs.None
        ul = @$ 'ul'

        for c in cons then do (c) =>
            con = new ActiveConstraint(@query, c)
            con.render().$el.appendTo ul
        
        @
        

