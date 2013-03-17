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

  moveRight = (xs, i) -> xs.splice i, 2, xs[i + 1], xs[i]

  shift = (model, toLeft) ->
    {models} = model.collection
    idx = models.indexOf(model)
    moveRight models, if toLeft then idx - 1 else idx
    model.collection.trigger 'reset'

  class ExportColumnHeader extends intermine.views.ItemView

    tagName: 'li'
    className: 'im-exported-col im-view-element'

    template: -> TEMPLATE

    events:
      "click .im-promote": "promote"
      "click .im-demote": "demote"
      "click .im-exclude": "toggle"
      "click .im-path": "toggle"

    promote: (e) -> shift @model, toLeft = true unless $(e.target).is '.disabled'

    demote: (e) -> shift @model, toLeft = false unless $(e.target).is '.disabled'

    toggle: -> @model.set excluded: not @model.get('excluded')

    initialize: ->
      @model.set excluded: false unless @model.has 'excluded'
      @$el.data {@model}
      @on 'rendered', @displayName, @
      @on 'rendered', @onChangeExclusion, @
      @on 'rendered', @checkShifters, @
      @model.on 'change:excluded', @onChangeExclusion, @

    checkShifters: ->
      idx = @model.collection.models.indexOf @model
      @$('.im-promote').toggleClass 'disabled', idx is 0
      @$('.im-demote').toggleClass 'disabled', idx + 1 is @model.collection.length

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

