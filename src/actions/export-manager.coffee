define 'actions/export-manager', ->

  class ExportManager extends intermine.views.ItemView

    tagName: 'li'

    className: 'im-data-export'

    initialize: (@states) -> super()

    template: _.template """
      <a class="btn im-open-dialogue">
        <i class="#{ intermine.icons.Export }"></i>
        <span class="visible-desktop">#{ intermine.messages.actions.ExportButton }</span>
      </a>
    """

    events: ->
      'click .im-open-dialogue': 'openDialogue'

    openDialogue: ->
      @dialogue?.remove()
      @dialogue = new intermine.query.export.ExportDialogue @states.currentQuery
      @$el.append @dialogue.render().el
      @dialogue.show()

