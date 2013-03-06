scope 'intermine.messages.columns',
  AddThisColumn: 'Add this column to the Sort Order'

do ->


  class OrderElement extends Backbone.Model

    isNumeric: false

    initialize: ->
      super arguments...
      @set direction: 'ASC' unless @has 'direction'
      @isNumeric = @get('path').getType() in intermine.Model.NUMERIC_TYPES

    toJSON: ->
      path: @get('path').toString()
      direction: @get('direction')

  class SortOrder extends Backbone.Collection

    model: OrderElement

    initialize: ->
      @on 'destroy', @remove, @

  class PossibleSortOrder extends Backbone.Model

    toSortOrder: -> path: @get('path')

    isInView: ->
      @get('path').toString() in @get('query').views

    initialize: ->
      @set visibleInView: true, matchesTerm: true
      @set path: @get('query').getPathInfo @get 'path'

    toJSON: ->
      isInView: @isInView()
      path: @get('path').toString()

  class PossibleOrderElements extends Backbone.Collection

    model: PossibleSortOrder

    initialize: ->
      @on 'destroy', @remove, @

  scope 'intermine.columns.collections', {SortOrder, PossibleOrderElements}

do ->

  class OrderElement extends Backbone.View

    TEMPLATE = _.template """
      <i class="icon-reorder pull-right"></i>
      <a class="pull-right im-remove-soe" href="#">
        <i class="icon-minus" title="Remove this column from the sort order"></i>
      </a>
      <a class="pull-left im-sort-direction <%= direction.toLowerCase() %>" href="#">
      </a>
      <span class="im-path" title="<%- path %>"><%- path %></span>
    """

    initialize: ->
      @model.on 'change:direction', =>
        @$('.im-sort-direction').toggleClass 'asc desc'
      @model.on 'destroy', @remove, @

    events:
      'click .im-sort-direction': 'changeDirection'
      'click .im-remove-soe': 'deorder'

    deorder: ->
      @options.possibles.add path: @model.get('path')
      @model.destroy()

    changeDirection: ->
      direction = if @model.get('direction') is 'ASC' then 'DESC' else 'ASC'
      @model.set {direction}

    remove: ->
      @model.off()
      @$('.im-remove-soe').tooltip 'hide'
      super()

    tagName: 'li'

    className: 'im-reorderable breadcrumb im-soe'

    render: ->

      @$el.addClass 'numeric' if @model.isNumeric

      @$el.append TEMPLATE @model.toJSON()

      @$('.im-remove-soe').tooltip()

      @model.get('path').getDisplayName().done (name) => @$('.im-path').text name

      this

  class PossibleOrderElement extends Backbone.View

    tagName: 'li'

    className: 'breadcrumb'

    TEMPLATE = _.template """
      <i class="icon-reorder pull-right"></i>
      <a class="pull-right im-add-soe"
         title="#{ intermine.messages.columns.AddThisColumn }" href="#">
        <i class="icon-plus"></i>
      </a>
      <span title="<%- path %>"><%- path %></span>
    """

    events:
      'im-add-soe': 'addToOrderBy'
      'dropped': 'addToOrderBy'

    addToOrderBy: ->
      @options.sortOrder.add @model.toSortOrder()
      @model.destroy()
      @remove()

    remove: ->
      @model.off()
      @$('.im-add-soe').tooltip 'hide'
      super()

    initialize: ->

      @model.on 'only-in-view', (only) =>
        @model.set visibleInView: not only or @model.isInView()

      @model.on 'filter', (pattern) =>
        @model.set matchesTerm: not pattern or pattern.test @model.get 'path'

      @model.on 'change', =>
        visible = @model.get('visibleInView') and @model.get('matchesTerm')
        @$el.toggle visible

    render: ->
      so = @model.toJSON()
      @$el.append TEMPLATE so

      unless so.isInView
        @$el.addClass 'im-not-in-view'

      @model.get('path').getDisplayName().done (name) => @$('span').text name

      @$el.draggable
        revert: 'invalid'
        revertDuration: 100

      @$(".im-add-soe").tooltip()

      this


  scope 'intermine.columns.views', {PossibleOrderElement, OrderElement}



