scope 'intermine.messages.results', {
    ReorderHelp: 'Drag the columns to reorder them'
}

scope 'intermine.messages.columns',
  AllowRevRef: 'Allow reverse references'
  CollapseAll: 'Collapse all branches'

do ->

    byEl = (el) -> (nv) -> nv.el is el

    {Tab} = intermine.bootstrap

    class ColumnAdder extends intermine.query.ConstraintAdder
        className: "form node-adder form-horizontal"

        initialize: (query, @newView) ->
            super(query)
            @chosen = []

        handleChoice: (path) =>
            if path in @chosen
                @chosen = _.without @chosen, path
            else
                @chosen.push(path)
            @applyChanges()
            $b = @$('.btn-chooser')
            $b.button('toggle') if $b.is('.active')

        handleSubmission: (e) =>
            e.preventDefault()
            e.stopPropagation()
            @applyChanges()

        applyChanges: () ->
          @newView.addPaths @chosen
          @reset()

        reset: ->
          super()
          @chosen = []

        refsOK: false
        multiSelect: true

        isDisabled: (path) => path.toString() in @query.views

        render: () ->
            super()
            @$('input').remove()
            @$('.btn-chooser > span').text intermine.messages.columns.FindColumnToAdd
            this

        showTree: (e) ->
          super(e)
          @$pathfinder?.$el.removeClass @$pathfinder.dropDownClasses


    class ViewNode extends Backbone.Model

        initialize: ->
          unless @has 'isNew'
            @set isNew: false
          unless @has 'replaces'
            @set replaces: []
          unless @has 'isFormatted'
            @set isFormatted: intermine.results.shouldFormat @get('path')
            
        addPath: (path) ->
          # using concat instead of push means we trigger 'change'
          @set replaces: @get('replaces').concat [path]

        getViews: -> if @get('replaces').length then @get('replaces') else [ @get('path') ]

        isAbove: (path, query) ->
          base = @get('path')
          if base.isAttribute()
            false
          if path.toString().indexOf(base.toString()) isnt 0
            false
          else if @get('isFormatted') and intermine.results.shouldFormat path
            myformatter = intermine.results.getFormatter base.append('id')
            theirformatter = intermine.results.getFormatter path
            myformatter is theirformatter
          else if path.containsCollection() and query.isOuterJoined(path)
            true
          else
            false

    class NewViewNodes extends Backbone.Collection
        model: ViewNode

        close: ->
          @off()
          @each (vn) -> vn?.off(); vn?.destroy()

        lengthOfPath = (vn) -> vn.get('path').allDescriptors().length

        initialize: (_, @options) ->

        addPaths: (paths) ->
          for path in paths
            group = @getGroup path
            if group?
              group.addPath path
            else
              @add {path: path, isNew: true}

        getGroup: (path) ->
          q = @options.query
          matches = @filter (vn) -> vn.isAbove(path, q)
          bestMatch = _.last _.sortBy matches, lengthOfPath
          return bestMatch

    class ColumnsDialogue extends Backbone.View
        tagName: "div"
        className: "im-column-dialogue modal"
        
        initialize: (@query, @columnHeaders) ->
          @columnHeaders ?= new Backbone.Collection
          @sortOpts = new Backbone.Model
          @sortOrder = new intermine.columns.collections.SortOrder
          @sortPossibles = new intermine.columns.collections.PossibleOrderElements
          @newView = new NewViewNodes [], {@query}

          @sortOrder.on 'add', @addSortElement
          @sortPossibles.on 'add', @addPossibleSortElement

          @sortOpts.on 'change:onlyInView', (m, only) =>
            @sortPossibles.each (m) -> m.trigger 'only-in-view', only
          @sortOpts.on 'change:filterTerm', (m, re) =>
            @sortPossibles.each (m) -> m.trigger 'filter', re

          @sortOrder.on 'destroy', (m) =>
            @sortPossibles.add {path: m.get('path'), @query}

          @newView.on 'add remove change', @drawOrder, @
          @newView.on 'destroy', (nv) => @newView.remove(nv)


        html: -> intermine.columns.snippets.ColumnsDialogue

        render: ->
          @$el.append @html()
          @initOrdering()
          @initSorting()

          @sortOpts.set onlyInView: true
          @$('i.im-sorting-help').popover
            placement: (popover) ->
              $(popover).addClass 'bootstrap'
              'left'
            trigger: 'hover'
            html: true
            title: intermine.messages.columns.SortingHelpTitle
            content: intermine.messages.columns.SortingHelpContent

          @$('.nav-tabs li a').each (i, e) =>
              $elem = $(e)
              $elem.data target: @$($elem.data("target"))

          this

        events:
            'hidden': 'onHidden'
            'click .btn-cancel': 'hideModal'
            'click .btn-primary': 'applyChanges'
            'click .nav-tabs li a': 'changeTab'
            'change input.im-only-in-view': 'onlyShowOptionsInView'
            'change .im-sortables-filter': 'filterSortables'
            'keyup .im-sortables-filter': 'filterSortables'
            'sortstop .im-sorting-container': 'onSortStop'
            'sortupdate .im-reordering-container': 'updateOrder'
            'sortupdate .im-sorting-container': 'updateSorting'

        onSortStop: (e, ui) ->
          {top, left} = ui.offset
          well = ui.item.closest '.well'
          wtop = well.offset().top
          removed = (top + ui.item.height() < wtop) or (top > wtop + well.height())
          oe = @sortOrder.find byEl ui.item[0]
          if removed
            _.defer -> oe.destroy() # Must be deferred or $.sortable will but the item back

        onHidden: (e) ->
          return false unless @el is e?.target
          @remove()
        
        remove: ->
          @sortOpts.off()
          @sortOrder.off()
          @sortPossibles.off()
          @newView.close()
          delete @newView
          delete @columnHeaders
          delete @sortOpts
          delete @sortOrder
          delete @sortPossibles
          @$el.empty()
          @undelegateEvents()
          @off()
          super()

        getFilterTerm: (e) ->
          $input = $ e.currentTarget
          term = $input.val()
          return unless term
          pattern = term.split(/\s+/).join('.*')
          new RegExp(pattern, 'i')

        filterSortables: (e) ->
          @sortOpts.set filterTerm: @getFilterTerm e

        onlyShowOptionsInView: (e) ->
          @sortOpts.set onlyInView: $(e.currentTarget).is ':checked'

        changeTab: (e) -> Tab.call $(e.currentTarget), "show"

        initOrdering: ->
          @newView.reset(model.toJSON() for model in @columnHeaders.models)
          @drawOrder()
          @drawSelector()

        drawOrder: ->
          colContainer = @$ '.im-reordering-container'
          colContainer.empty()
          colContainer.tooltip
            title: intermine.messages.results.ReorderHelp
            placement: intermine.utils.addStylePrefix 'top'

          @newView.each (model) =>
            view = new intermine.columns.views.ViewElement {model}
            colContainer.append view.render().el

          colContainer.sortable
            items: 'li.im-reorderable'
            axis: 'y'
            forcePlaceholderSize: true
            placeholder: 'im-resorting-placeholder'


        drawSelector: ->
            selector = '.im-reordering .well'
            nodeAdder = @$ '.node-adder'
            @ca?.remove()
            ca = new ColumnAdder(@query, @newView)
            nodeAdder.empty().append ca.render().el
            ca.on 'showing:tree', => @$(selector).slideUp()
            ca.on 'resetting:tree', => @$(selector).slideDown()
            @ca = ca

        updateOrder: (e, ui) ->
            # The update event doesn't just tell us what has changed, so we have read the 
            # order out of the DOM. Urgh.
            lis = @$ '.im-view-element'
            byEl = (el) -> (nv) -> nv.el is el
            reorderedState = (@newView.find byEl el for el in lis.get())
            @newView.reset reorderedState

        updateSorting: (e, ui) ->
          lis = @$ '.im-in-order'
          byEl = (el) -> (oe) -> oe.el is el
          reorderedState = (@sortOrder.find byEl el for el in lis.get())
          @sortOrder.reset reorderedState

        sortingPlaceholder: """
            <div class="placeholder">
                Drop columns here.
            </div>
        """

        makeSortOrderElem: (model) ->
          possibles = @sortPossibles
          soe = new intermine.columns.views.OrderElement {model, possibles}
          soe.render().el

        makeSortOption: (model) ->
          option = new intermine.columns.views.PossibleOrderElement {model, @sortOrder}
          option.render().el

        initSorting: ->
          container = @$('.im-sorting-container').empty().append(@sortingPlaceholder)
          @$('.im-sorting-container-possibilities').empty()

          container.sortable()
          container.parent().droppable
            drop: (event, ui) -> $(ui.draggable).trigger 'dropped'

          @buildSortOrder()
          @buildPossibleSortOrder()

        buildSortOrder: ->
          @sortOrder.reset []

          for so, i in (@query.sortOrder or [])
            {path, direction} = so
            @sortOrder.add
              path: @query.getPathInfo path
              direction: direction

        buildPossibleSortOrder: ->
          @sortPossibles.reset []

          isSorted = (v) => @query.getSortDirection v
          isOuter = (v) => @query.isOuterJoined v
          inView = (v) => "#{ v }" in @query.views

          test0 = (path) -> not isSorted(path) and not isOuter(path)
          test1 = (p) -> p.isAttribute() and not inView(p) and not isSorted(p)

          for path in @query.views when test0 path
            @sortPossibles.add {path, @query}

          for n in @query.getViewNodes() when not isOuter n
            for path in n.getChildNodes() when test1 path
              @sortPossibles.add {path, @query}
        
        addSortElement: (m) =>
          container = @$ '.im-sorting-container'
          elem = @makeSortOrderElem m
          container.append elem

        addPossibleSortElement: (m) =>
          possibilities = @$ '.im-sorting-container-possibilities'
          elem = @makeSortOption m
          possibilities.append elem

        hideModal: -> @$el.modal 'hide'

        showModal: -> @$el.modal show: true

        applyChanges: (e) ->
            if @$('.im-reordering').is('.active')
                @changeOrder(e)
            else
                @changeSorting(e)

        changeOrder: (e) ->
            newViews = _.flatten @newView.map (v) -> v.getViews()
            @hideModal()
            @query.select(newViews)

        changeSorting: (e) ->
            newSO = (so.toJSON() for so in @sortOrder.models)
            @hideModal()
            @query.orderBy(newSO)

    scope "intermine.query.results.table", {ColumnsDialogue}

