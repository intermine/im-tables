do ->

  TEMPLATE = """
    <div>
      <div class="pull-right im-promoters">
        <i class="#{intermine.icons.MoveUp} im-promote"></i>
        <i class="#{intermine.icons.MoveDown} im-demote"></i>
      </div>
      <i class="#{intermine.icons.Check} im-exclude"></i>
      <span class="im-path"></span>
    </div>
  """

  NAME_TEMPLATE = _.template """<span class="im-name-part"><%- part %></span>"""

  class ExportColumnHeader extends intermine.views.ItemView

    tagName: 'li'
    className: 'im-exported-col im-view-element'

    template: -> TEMPLATE

    events:
      "click .im-promote": "promote"
      "click .im-demote": "demote"
      "click .im-exclude": "toggle"
      "click .im-path": "toggle"

    promote: ->
      {models} = @model.collection
      idx = models.indexOf(@model)
      models.splice idx - 1, 2, models[idx], models[idx - 1]
      @model.collection.trigger 'reset'

    demote: ->

    toggle: ->
      @model.set excluded: not @model.get('excluded')

    initialize: ->
      @model.set excluded: false unless @model.has 'excluded'
      @$el.data {@model}
      @on 'rendered', @displayName, @
      @on 'rendered', @onChangeExclusion, @
      @model.on 'change:excluded', @onChangeExclusion, @

    onChangeExclusion: ->
      excl = @model.get 'excluded'
      @$('.im-exclude').toggleClass(intermine.icons.Check, not excl)
                        .toggleClass(intermine.icons.UnCheck, excl)
      @$el.toggleClass 'im-excluded', excl

    displayName: ->
      @model.get('path').getDisplayName().done (dname) =>
        parts = dname.split ' > '
        $path = @$('.im-path')
        for part in parts
          $path.append NAME_TEMPLATE {part}

  scope 'intermine.columns.views', {ExportColumnHeader}

