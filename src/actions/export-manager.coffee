define 'actions/export-manager', ->

  class ExportManager extends intermine.views.ItemView

    tagName: 'li'

    className: 'im-data-export'

    initialize: (@states) -> super()

    template: _.template """
      <a class="btn im-open-dialogue" href="#">
        <i class="#{ intermine.icons.Export }"></i>
        #{ intermine.messages.actions.ExportButton }
      </a>
    """

    events: ->
      'click .im-open-dialogue': 'openDialogue'

    openDialogue: ->
      @dialogue?.remove()
      @dialogue = new intermine.query.export.ExportDialogue @states.currentQuery
      @$el.append @dialogue.render().el
      @dialogue.show()

