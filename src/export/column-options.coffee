do ->

  NODE_HTML = _.template """
     <div>
       <i class="<%= icon %>"></i>
       <span class="im-display-name"></span>
     </div>
  """

  class SelectableNode extends Backbone.View
    tagName: 'li'
    className: 'im-selectable-node im-view-element'

    initialize: ->
      @model.on 'change:included', @render
      @model.on 'destroy', @remove, @

    events:
      'click': 'toggleIncluded'

    toggleIncluded: ->
      @model.set included: not @model.get('included')

    render: =>
      {path, included} = @model.toJSON()
      {Check, UnCheck} = intermine.icons
      icon = if included then Check else UnCheck
      @$el.html NODE_HTML {icon}
      @$el.toggleClass 'included', included
      path.getDisplayName (name) => @$('.im-display-name').text name
      this

  class ExportColumnOptions extends Backbone.View

    tagName: 'label'
    className: 'export-column-options'

    TEMPLATE = (ctx) -> _.template """
      <div class="control-label">
        <%= message %>
        <span class="im-selected-count">0</span> selected.
        <div class="btn im-clear disabled">
          #{ intermine.messages.actions.Clear }
        </div>
      </div>
      <div class="well">
        <ul class="im-export-paths nav nav-tabs nav-stacked"></ul>
      </div>
    """, ctx

    COUNT_INCLUDED = (sum, m) -> if m.get('included') then ++sum else sum

    initialize: ->
      @paths = col = @collection ? throw new Error('collection required')
      @listenTo col, 'change:included', @update
      @listenTo col, 'add', @insert
      @listenTo col, 'add', @update
      @listenTo col, 'close', @remove, @

    insert: (m) =>
      @$('.im-export-paths').append new SelectableNode(model: m).render().el

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
      if @paths.isEmpty()
        @$('.im-export-paths').append """
          <li>
            <span class="label label-important">
            #{ intermine.messages.actions.NoSuitableColumns}
            </span>
          </li>
        """
      else
        @insert m for m in @paths.models

      @paths.trigger 'change:included'

      this

  scope 'intermine.actions', {ExportColumnOptions}
