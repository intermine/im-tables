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

  NAME_TEMPLATE = _.template """
    <% _.each(parents, function(parent) { %>
      <span class="im-parent"><%- parent %></span>
    <% }); %>
    <span class="im-display-name"><%- name %></span>
  """

  class ExportColumnHeader extends intermine.views.ItemView

    tagName: 'li'
    className: 'im-exported-col'

    template: -> TEMPLATE

    events:
      "click .im-promote": "promote"
      "click .im-demote": "demote"
      "click .im-exclude": "toggle"
      "click .im-path": "toggle"

    promote: ->

    demote: ->

    toggle: ->
      @model.set excluded: not @model.get('excluded')

    initialize: ->
      @model.set excluded: false unless @model.has 'excluded'
      @$el.data {@model}
      @on 'rendered', @displayName, @
      @model.on 'change:excluded', (m, excluded) =>
        @$el.toggleClass 'im-excluded', excluded
        @$('.im-exclude').toggleClass intermine.icons.CheckUnCheck

    displayName: ->
      @model.get('path').getDisplayName().done (dname) =>
        [parents..., penult, name] = dname.split ' > '
        @$('.im-path').append NAME_TEMPLATE {parents: parents.concat([penult]), name}
        if parents.length
          @$el.find('.im-parent').last().show()

  scope 'intermine.columns.views', {ExportColumnHeader}

