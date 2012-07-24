scope 'intermine.filters', (exporting) ->

    exporting class NewFilterDialogue extends Backbone.View
        tagName: "div"
        className: "im-constraint-dialogue modal fade"

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
            'hidden': 'remove'
            'click .im-add-constraint': 'addConstraint'

        closeDialogue: (e) -> @$el.modal('hide')

        openDialogue: () -> @$el.modal().modal('show')

        addConstraint: () ->
            if @conAdder.isValid()
                @$el.modal('hide')
                @$('.im-constraint.new .btn-primary').click()
            else
                @$('.im-constraint.new').addClass('error')

        render: () ->
            @$el.append @html
            @conAdder = new intermine.query.ConstraintAdder(@query)
            @$el.find('.modal-body').append @conAdder.render().el
            this
            
