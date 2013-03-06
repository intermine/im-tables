scope 'intermine.messages.results', {
    ReorderHelp: 'Drag the columns to reorder them'
}

scope 'intermine.messages.columns', {
    OrderTitle: 'Add / Remove / Re-Arrange Columns',
    SortTitle: 'Define Sort-Order',
    OnlyColsInView: 'Only show columns in the table:',
    SortingHelpTitle: 'What Columns Can I Sort by?',
    SortingHelpContent: """
      A table can be sorted by any of the attributes of the objects
      which are in the output columns or constrained by a filter, so
      long as they haven't been declared to be optional parts of the
      query. So if you are displaying <span class="label path">Gene > Name</span>
      and <span class="label path">Gene > Exons > Symbol</span>, and also
      <span class="label path">Gene > Proteins > Name</span> if the gene
      has any proteins (ie. the proteins part of the query is optional), then
      you can sort by any of the attributes attached to
      <span class="label path available">Gene</span>
      or <span class="label path available">Gene > Exons</span>,
      whether or not you have selected them for output, but you could not sort by
      any of the attributes of <span class="label path available">Gene > Proteins</span>,
      since these items may not be present in the results.
    """
}

do ->

    class OuterJoinGroup extends Backbone.View
        tagName: 'li'
        className: 'im-reorderable breadcrumb'

        initialize: (@query, @newView) ->
            @newView.on 'destroy', @remove, @

        render: () ->
            @$el.append '<i class="icon-reorder pull-right"></i>'
            @$el.append """
                <a href="#" class="pull-left im-col-remover" title="Remove these columns">
                    <i class="#{ intermine.icons.Remove }"></i>
                </a>
            """
            rem = @$('.im-col-remover').tooltip().click (e) =>
                e.stopPropagation()
                rem.tooltip('hide')
                @newView.destroy()
            h4 = $ '<h4>'
            @$el.append h4
            @newView.get('path').getDisplayName (name) -> h4.text name
            @$el.data 'path', @newView.get('path').toString()
            ul = $ '<ul>'
            for key in _.sortBy(_.keys(@newView.nodes), (k) -> k.length) then do (key) =>
                paths = @newView.nodes[key]
                for p in paths then do (p) =>
                    li = $ """
                        <li class="im-outer-joined-path">
                            <a href="#"><i class="#{intermine.icons.Remove}"></i></a>
                            <span></span>
                        </li>
                    """
                    ul.append li
                    li.find('a').click (e) =>
                        e.stopPropagation()
                        @newView.set paths: _.without @newView.get('paths'), p

                    li.toggleClass 'new', !!@newView.newPaths[p.toString()]
                    p.getDisplayName (name) =>
                        @newView.get('path').getDisplayName (ojname) ->
                            li.find('span')
                              .text(name.replace(ojname, '').replace(/^\s*>?\s*/, ''))
            @$el.append ul
            this


    class ColumnAdder extends intermine.query.ConstraintAdder
        className: "form node-adder btn-group"

        initialize: (query) ->
            super(query)
            @chosen = []

        handleChoice: (path) =>
            if _.include @chosen, path
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
            @query.trigger 'column-orderer:selected', @chosen
            @reset()

        reset: () ->
            super()
            @chosen = []
            # Ugliness ahead...
            #$b = @$('.btn-chooser')
            #$b.button('toggle') if $b.is('.active')
            #@$('.btn-primary').fadeOut('slow')

        refsOK: false
        multiSelect: true

        isDisabled: (path) => path.toString() in @query.views

        render: () ->
            super()
            @$('input').remove()
            this

    class ViewNode extends Backbone.Model

        initialize: ->
            @newPaths = {}
            if @get 'isOuterJoined'
                @nodes =  _.groupBy @get('paths'), (p) -> p.getParent().toString()
            unless @has 'isNew'
                @set isNew: false
            
        addPath: (path) ->
            node = @nodes[path.getParent().toString()]
            unless node?
                node = @nodes[path.getParent().toString()] = []
            node.push path
            @newPaths[path.toString()] = true
            @trigger "change"
            @trigger "change:paths"

        getViews: () ->
            if @get 'isOuterJoined'
                ret = []
                for key in _.sortBy(_.keys(@nodes), (k) -> k.length) then do (key) =>
                    node = @nodes[key]
                    for p in node
                        ret.push p.toString()
            else
                ret = [@get('path').toString()]
            ret

    class NewViewNodes extends Backbone.Collection
        model: ViewNode

    class ColumnsDialogue extends Backbone.View
        tagName: "div"
        className: "im-column-dialogue modal fade"
        
        initialize: (@query) ->
          @sortOpts = new Backbone.Model
          @sortOrder = new intermine.columns.collections.SortOrder
          @sortPossibles = new intermine.columns.collections.PossibleOrderElements
          @newView = new NewViewNodes()

          @sortOrder.on 'add', @addSortElement
          @sortPossibles.on 'add', @addPossibleSortElement

          @sortOpts.on 'change:onlyInView', (m, only) =>
            @sortPossibles.each (m) -> m.trigger 'only-in-view', only
          @sortOpts.on 'change:filterTerm', (m, re) =>
            @sortPossibles.each (m) -> m.trigger 'filter', re

          @newView.on 'add remove change', @drawOrder, @
          @newView.on 'destroy', (nv) => @newView.remove(nv)
          @query.on 'column-orderer:selected', (paths) =>
            for path in paths
              pstr = path.toString()
              if @query.isOuterJoined(pstr)
                ojgs = @newView.filter( (nv) -> nv.get('isOuterJoined') )
                               .filter( (nv) -> !!pstr.match(nv.get('path').toString()) )
                ojg = _.last(_.sortBy(ojgs, (nv) -> nv.get('path').descriptors.length))
                ojg.addPath(@query.getPathInfo(pstr))
              else
                @newView.add {path: @query.getPathInfo(pstr), isNew: true}

        html: """
         <div class="modal-header">
           <a class="close" data-dismiss="modal">close</a>
           <h3>Manage Columns</a>
         </div>
         <div class="modal-body">
           <ul class="nav nav-tabs">
             <li class="active">
               <a data-target=".im-reordering" data-toggle="tab">
                 #{ intermine.messages.columns.OrderTitle }
               </a>
             </li>
             <li>
               <a data-target=".im-sorting" data-toggle="tab">
                 #{ intermine.messages.columns.SortTitle }
               </a>
             </li>
           </ul>
           <div class="tab-content">
             <div class="tab-pane fade im-reordering active in">
               <div class="node-adder"></div>
               <ul class="im-reordering-container well"></ul>
             </div>
             <div class="tab-pane fade im-sorting">
               <ul class="im-sorting-container well"></ul>
               <form class="form-search">
                <i class="#{ intermine.icons.Help } pull-right im-sorting-help"></i>
                <div class="input-prepend">
                  <span class="add-on">filter</span>
                  <input type="text" class="search-query im-sortables-filter">
                </div>
                <label class="im-only-in-view">
                  #{ intermine.messages.columns.OnlyColsInView }
                  <input class="im-only-in-view" type="checkbox" checked>
                </label>
               </form>
               <ul class="im-sorting-container-possibilities well"></ul>
             </div>
           </div>
         </div>
         <div class="modal-footer">
           <a class="btn btn-cancel">
             Cancel
           </a>
           <a class="btn pull-right btn-primary">
             Apply
           </a>
         </div>
        """

        viewTemplate: _.template """
          <li class="im-reorderable breadcrumb<% if (isNew) {%> new<% } %>"
              data-path="<%- path %>">
            <i class="icon-reorder pull-right""></i>
            <a class="pull-left im-col-remover" title="Remove this column" href="#">
              <i class="#{ intermine.icons.Remove }"></i>
            </a>
            <h4 class="im-display-name"><%- path %></span>
          </li>
        """

        render: ->
          @$el.append @html
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
            'hidden': 'remove'
            'click .btn-cancel': 'hideModal'
            'click .btn-primary': 'applyChanges'
            'click .nav-tabs li a': 'changeTab'
            'change input.im-only-in-view': 'onlyShowOptionsInView'
            'change .im-sortables-filter': 'filterSortables'
            'keyup .im-sortables-filter': 'filterSortables'
            'sortupdate .im-reordering-container': 'updateOrder'

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

        changeTab: (e) -> $(e.target).tab("show")

        initOrdering: ->
          @newView.reset()
          @ojgs = {}
          for v in @query.views
            path = @query.getPathInfo v
            isOuterJoined = @query.isOuterJoined v
            if isOuterJoined
               # Find oj closest to root
               oj = if @query.joins[path.toString()] is 'OUTER' then path else null
               node = path
               while !node?.isRoot()
                 node = node.getParent()
                 oj = if @query.joins[node.toString()] is 'OUTER' then node else oj
               ojStr = oj.toString()
               unless @ojgs[ojStr] # Done this one already
                 paths = (@query.getPathInfo v for v in @query.views when v.match ojStr)
                 path = oj
                 @newView.add {path, paths, isOuterJoined}, {silent: true}
                 @ojgs[ojStr] = @newView.last()
            
            else
              @newView.add {path, isOuterJoined}, {silent: true}
          @drawOrder()
          @drawSelector()

        drawOrder: ->
            colContainer = @$ '.im-reordering-container'
            colContainer.empty()
            colContainer.tooltip
                title: intermine.messages.results.ReorderHelp
                placement: 'top'

            @newView.each (newView, i) =>
                if newView.get 'isOuterJoined'
                    ojg = new OuterJoinGroup(@query, newView)
                    moveableView = ojg.render().el
                else
                    path = newView.get('path')
                    moveableView = $ @viewTemplate newView.toJSON()
                    rem = moveableView.find('.im-col-remover').tooltip().click (e) ->
                        rem.tooltip('hide')
                        moveableView.remove()
                        newView.destroy()
                        e.stopPropagation()
                    isFormatted = path.isAttribute and (path.end?.name is 'id') and intermine.results.getFormatter(@query.model, path.getParent().getType())?
                    toShow = if isFormatted then path.getParent() else path
                    toShow.getDisplayName (name) -> moveableView.find('.im-display-name').text(name)

                colContainer.append moveableView
            colContainer.sortable items: 'li.im-reorderable'

        drawSelector: ->
            nodeAdder = @$ '.node-adder'
            ca = new ColumnAdder(@query)
            nodeAdder.empty().append ca.render().el

        updateOrder: (e, ui) ->
            lis = @$('.im-reordering-container li')
            paths = lis.map( (i, e) -> $(e).data('path')).get()
            newView = paths.map( (p) => @newView.find( (nv) -> p is nv.get('path').toString() ))
            @newView.reset( newView )


        sortingPlaceholder: """
            <div class="placeholder">
                Drop columns here.
            </div>
        """

        makeSortOrderElem: (model) ->
          soe = new intermine.columns.views.OrderElement {model}
          soe.render().el

        makeSortOption: (model) ->
          option = new intermine.columns.views.PossibleOrderElement {model, @sortOrder}
          option.render().el

        initSorting: ->
          container = @$('.im-sorting-container').empty().append(@sortingPlaceholder)
          @$('.im-sorting-container-possibilities').empty()

          container.sortable().droppable
            drop: (event, ui) -> $(ui.draggable).trigger 'dropped'

          @buildSortOrder()
          @buildPossibleSortOrder()

        buildSortOrder: ->
          @sortOrder.reset []

          for so, i in (@query.sortOrder or [])
            {path, direction} = so
            @sortOrder.add new intermine.columns.SortOrder
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

          for n in @query.getQueryNodes() when not isOuter n
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
            lis = @$('.im-sorting-container li')
            newSO = lis.map( (i, e) -> {path: $(e).data('path'), direction: $(e).data("direction")}).get()
            @hideModal()
            @query.orderBy(newSO)

    scope "intermine.query.results.table", {ColumnsDialogue}

