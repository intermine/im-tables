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

  placement = intermine.utils.addStylePrefix 'top'

  class OrderElement extends Backbone.View

    tagName: 'li'

    className: 'im-reorderable im-soe'

    TEMPLATE = _.template """
      <div>
        <span class="im-sort-direction <%= direction.toLowerCase() %>"></span>
        <i class="icon-minus im-remove-soe" title="Remove this column from the sort order"></i>
        <span class="im-path" title="<%- path %>"><%- path %></span>
        <i class="icon-reorder pull-right"></i>
      </div>
    """

    initialize: ->
      @model.on 'change:direction', =>
        @$('.im-sort-direction').toggleClass 'asc desc'
      @model.on 'destroy', @remove, @

    events:
      'click .im-sort-direction': 'changeDirection'
      'click .im-remove-soe': 'deorder'

    deorder: -> @model.destroy()

    changeDirection: ->
      direction = if @model.get('direction') is 'ASC' then 'DESC' else 'ASC'
      @model.set {direction}

    remove: ->
      @model.off()
      @$('.im-remove-soe').tooltip 'hide'
      super()


    render: ->

      @$el.addClass 'numeric' if @model.isNumeric

      @$el.append TEMPLATE @model.toJSON()

      @$('.im-remove-soe').tooltip {placement}

      @model.get('path').getDisplayName().done (name) => @$('.im-path').text name

      this

  class PossibleOrderElement extends Backbone.View

    tagName: 'li'

    className: 'im-soe'

    TEMPLATE = _.template """
      <div>
        <a href="#" class="im-add-soe"
           title="#{ intermine.messages.columns.AddThisColumn }" >
          <i class="icon-plus"></i>
          <span title="<%- path %>"><%- path %></span>
        </a>
        <i class="icon-reorder pull-right"></i>
      </div>
    """

    events:
      'click .im-add-soe': 'addToOrderBy'
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

      @$(".im-add-soe").tooltip {placement}

      this


  scope 'intermine.columns.views', {PossibleOrderElement, OrderElement}



