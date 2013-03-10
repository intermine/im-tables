do ->

  class SelectableNode extends Backbone.View
    tagName: 'li'
    className: 'im-selectable-node'

    initialize: ->
      @model.on 'change:included', @render

    events:
      'click a': 'toggleIncluded'

    toggleIncluded: ->
      @model.set included: !@model.get('included')

    render: =>
      {path, included} = @model.toJSON()
      labelClass = if included then 'label-included' else 'label-available'
      path.getDisplayName (name) => @$el.empty().append """
        <span class="label #{ labelClass }">
            <a href="#">
              #{ name }
            </a>
        </span>
      """
      @

  class ExportColumnOptions extends Backbone.View

    tagName: 'label'
    className: 'export-column-options'

    TEMPLATE = (ctx) -> _.template """
      <span class="span4 im-left-col control-label">
        <i class="im-collapser #{ intermine.icons.Expanded }"></i>
         <%= message %>
        <span class="im-selected-count">0</span> selected.
        <div class="btn im-clear disabled">
          #{ intermine.messages.actions.Clear }
        </div>
      </span>
      <ul class="well span8 im-export-paths">
      </ul>
    """, ctx

    COUNT_INCLUDED = (sum, m) -> if m.get('included') then ++sum else sum

    initialize: ->
      @paths = @collection ? throw new Error('collection required')
      @paths.on 'change:included', @update
      @paths.on 'add', @insert
      @paths.on 'add', @update
      @paths.on 'ready', @ready

    insert: (m) =>
      @$('.im-export-paths').append new SelectableNode(model: m).render().el

    ready: =>
      if @paths.isEmpty()
        @$('.im-export-paths').append """
          <li>
            <span class="label label-important">
            #{ intermine.messages.actions.NoSuitableColumns}
            </span>
          </li>
        """

    events:
      'click .im-clear': 'clear'
      'click .im-collapser': 'toggle'

    clear: ->
      @paths.each (m) -> m.set included: false

    toggle: ->
      @$('.im-export-paths').slideToggle()
      @$('.im-left-col').toggleClass 'span4 span10'
      @$('.im-collapser').toggleClass intermine.icons.ExpandCollapse

    update: =>
      c = @paths.reduce COUNT_INCLUDED, 0
      @$('.im-selected-count').text c
      @$('.im-clear').toggleClass 'disabled', c < 1
      @$el.toggleClass 'error', not @isValidCount c

    isValidCount: -> true

    render: ->
      @$el.append TEMPLATE message: @options.message
      this

  scope 'intermine.actions', {ExportColumnOptions}
