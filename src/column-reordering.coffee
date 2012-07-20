scope 'intermine.messages.results', {
    ReorderHelp: 'Drag the columns to reorder them'
}

scope "intermine.query.results.table", (exporting) ->

    class OuterJoinGroup extends Backbone.View
        tagName: 'li'
        className: 'im-reorderable breadcrumb'

        initialize: (@query, @newView) ->
            @ojg = @newView.get('path')
            paths = (@query.getPathInfo(v) for v in @newView.get('paths'))
            @nodes = _.groupBy(paths, (p) -> p.getParent().toString())
            @newView.on 'destroy', @remove, @

        getViews: () ->
            ret = []
            for key in _.sortBy(_.keys(@nodes), (k) -> k.length) then do (key) =>
                node = @nodes[key]
                for p in node
                    ret.push p.toString()
            ret

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
            @ojg.getDisplayName (name) -> h4.text name
            @$el.data 'path', @ojg.toString()
            ul = $ '<ul>'
            for key in _.sortBy(_.keys(@nodes), (k) -> k.length) then do (key) =>
                paths = @nodes[key]
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
                        @newView.set paths: _.without @newView.get('paths'), p.toString()

                    p.getDisplayName (name) =>
                        @ojg.getDisplayName (ojname) ->
                            li.find('span').text name.replace(ojname, '').replace(/^\s*>?\s*/, '')
            @$el.append ul
            this

        addPath: (path) ->
            pi = @query.getPathInfo(path)
            node = @nodes[pi.getParent().toString()]
            unless node?
                node = @nodes[pi.getParent().toString()] = []
            node.push pi
            @$el.empty()
            @render()

    class ColumnAdder extends intermine.query.ConstraintAdder
        className: "form node-adder btn-group"

        initialize: (query) ->
            super(query)
            @chosen = []

        handleChoice: (path) =>
            @chosen.push(path) unless _.include(@chosen, path)
            @$('.btn-primary').attr disabled: false

        handleSubmission: (e) =>
            e.preventDefault()
            e.stopPropagation()
            @query.trigger 'column-orderer:selected', @chosen
            @reset()

        reset: () ->
            super()
            @chosen = []
            @$('.btn-chooser').button('reset')
            @$('.btn-primary').attr disabled: true

        refsOK: false
        multiSelect: true

        isDisabled: (path) => path.toString() in @query.views

        render: () ->
            super()
            @$('input').remove()
            this

    exporting class ColumnsDialogue extends Backbone.View
        tagName: "div"
        className: "im-column-dialogue modal fade"
        
        initialize: (@query) ->
            @newView = new Backbone.Collection()
            @newView.on 'add remove change', @drawOrder, @
            @newView.on 'destroy', (nv) => @newView.remove(nv)
            @query.on 'column-orderer:selected', (paths) =>
                for path in paths
                    pstr = path.toString()
                    if @query.isOuterJoined(pstr)
                        ojgs = @newView.filter( (nv) -> nv.get('isOuterJoined') )
                                       .filter( (nv) -> !!pstr.match(nv.get('path').toString()) )
                        ojg = _.last(_.sortBy(ojgs, (nv) -> nv.get('path').descriptors.length))
                        ojg.get('paths').push(pstr)
                        @newView.trigger 'change'
                    else
                        @newView.add {path: @query.getPathInfo(pstr), paths: [pstr]}

        html: """
         <div class="modal-header">
             <a class="close" data-dismiss="modal">close</a>
             <h3>Manage Columns</a>
         </div>
         <div class="modal-body">
             <ul class="nav nav-tabs">
                 <li class="active">
                     <a data-target=".im-reordering" data-toggle="tab">
                         Re-Order Columns
                     </a>
                 </li>
                 <li>
                     <a data-target=".im-sorting" data-toggle="tab">
                     Re-Sort Columns
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
            <li class="im-reorderable breadcrumb" data-path="<%- path %>">
                <i class="icon-reorder pull-right""></i>
                <a class="pull-left im-col-remover" title="Remove this column" href="#">
                    <i class="#{ intermine.icons.Remove }"></i>
                </a>
                <h4 class="im-display-name"><%- displayName %></span>
            </li>
        """

        render: ->
            @$el.append @html
            @initOrdering()
            @initSorting()

            @$('.nav-tabs li a').each (i, e) =>
                $elem = $(e)
                $elem.data target: @$($elem.data("target"))

            this

        events:
            'hidden': 'remove'
            'click .btn-cancel': 'hideModal'
            'click .btn-primary': 'applyChanges'
            'click .nav-tabs li a': 'changeTab'
            'click .im-soe .im-remove-soe': 'removeSortOrder'
            'click .im-add-soe': 'addSortOrder'
            'click .im-sort-direction': 'sortCol'
            'sortupdate .im-reordering-container': 'updateOrder'

        changeTab: (e) -> $(e.target).tab("show")

        initOrdering: ->
            @newView.reset()
            @ojgs = {}
            for v in @query.views
                path = @query.getPathInfo v
                paths = [v]
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
                        paths = @query.views.filter((v) -> v.match(ojStr))
                        path = oj
                        @newView.add {path, paths, isOuterJoined}, {silent: true}
                        @ojgs[ojStr] = @newView.last()
                
                else
                    @newView.add {path, paths, isOuterJoined}, {silent: true}
            @drawOrder()

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
                    moveableView = $ @viewTemplate displayName: path, path: path
                    rem = moveableView.find('.im-col-remover').tooltip().click (e) ->
                        rem.tooltip('hide')
                        moveableView.remove()
                        newView.destroy()
                        e.stopPropagation()
                    path.getDisplayName (name) -> moveableView.find('.im-display-name').text(name)

                colContainer.append moveableView

            nodeAdder = @$ '.node-adder'
            ca = new ColumnAdder(@query)
            nodeAdder.empty().append ca.render().el
            colContainer.sortable items: 'li'

        updateOrder: (e, ui) ->
            lis = @$('.im-reordering-container li')
            paths = lis.map( (i, e) -> $(e).data('path')).get()
            newView = paths.map( (p) => @newView.find( (nv) -> p is nv.get('path').toString() ))
            @newView.reset( newView )

        sortCol: (e) ->
            $elem = $(e.target).parent()
            newDirection = if $elem.data("direction") is "ASC" then "DESC" else "ASC"
            $elem.data direction: newDirection
            $(e.target).toggleClass "asc desc"

        soTemplate: _.template """
            <li class="im-reorderable breadcrumb im-soe" data-path="<%- path %>" data-direction="<%- direction %>">
                <i class="icon-reorder pull-right"></i>
                <a class="pull-right im-remove-soe" href="#">
                    <i class="icon-minus" title="Remove this column from the sort order"></i>
                </a>
                <a class="pull-left im-sort-direction <% if (direction === 'ASC') { %>asc<% } else { %>desc<% } %>" href="#"></a>
                <span class="im-path" title="<%- path %>"><%- path %></span>
            </li>
        """

        possibleSortOptionTemplate: _.template """
            <li class="breadcrumb" data-path="<%- path %>">
                <i class="icon-reorder pull-right"></i>
                <a class="pull-right im-add-soe" title="Add this column to the sort order" href="#">
                    <i class="icon-plus"></i>
                </a>
                <span title="<%- path %>"><%- path %></span>
            </li>
        """

        removeSortOrder: (e) ->
            $elem = $(e.target).closest('.im-soe')
            path = $elem.data "path"
            $('.tooltip').remove()
            $elem.find('.im-remove-soe').tooltip("hide")
            $elem.remove()
            possibilities = @$ '.im-sorting-container-possibilities'
            psoe = $ @possibleSortOptionTemplate path: path
            do (psoe) => @query.getPathInfo(path).getDisplayName (name) ->
                psoe.find('span').text name
            psoe.draggable
                revert: "invalid"
                revertDuration: 100
            psoe.find(".im-add-soe").tooltip()
            possibilities.append psoe

        addSortOrder: (e) ->
            $elem = $(e.target).closest('.breadcrumb')
            path = $elem.data "path"
            $elem.find('.im-add-soe').tooltip('hide')
            $elem.remove()
            @$('.im-sorting-container').append @makeSortOrderElem path: path, direction: "ASC"

        sortingPlaceholder: """
            <div class="placeholder">
                Drop columns here.
            </div>
        """

        makeSortOrderElem: (so) ->
            soe = $ @soTemplate so
            @query.getPathInfo(so.path).getDisplayName (name) -> soe.find('.im-path').text name
            soe.addClass("numeric") if @query.getPathInfo(so.path).getType() in intermine.Model.NUMERIC_TYPES
            soe.find('.im-remove-soe').tooltip()
            soe

        makeSortOption: (path) ->
            option = $ @possibleSortOptionTemplate path: path
            do (option) => @query.getPathInfo(path).getDisplayName (name) ->
                option.find('span').text name
            return option

        initSorting: =>
            container = @$ '.im-sorting-container'
            container.empty().append(@sortingPlaceholder)
            for so, i in (@query.sortOrder or [])
                container.append @makeSortOrderElem(so)

            possibilities = @$ '.im-sorting-container-possibilities'
            possibilities.empty()
            for v in @query.views when not @query.getSortDirection(v) and not @query.isOuterJoined(v)
                possibilities.append @makeSortOption v

            for n in @query.getQueryNodes() when not @query.isOuterJoined n.toPathString()
                for cn in n.getChildNodes() when cn.isAttribute() and cn.toPathString() not in @query.views
                    possibilities.append @makeSortOption cn.toPathString()

            possibilities.find("li").draggable
                revert: "invalid"
                revertDuration: 100
            possibilities.find(".im-add-soe").tooltip()

            container.sortable().droppable
                drop: (event, ui) =>
                    path = $(ui.draggable).data("path")
                    $(ui.draggable).remove()
                    container.append @makeSortOrderElem path: path, direction: "ASC"

        hideModal: -> @$el.modal 'hide'

        showModal: -> @$el.modal show: true

        applyChanges: (e) ->
            if @$('.im-reordering').is('.active')
                @changeOrder(e)
            else
                @changeSorting(e)

        changeOrder: (e) ->
            newViews = _.flatten @newView.map (v) -> v.get 'paths'
            @hideModal()
            @query.select(newViews)

        changeSorting: (e) ->
            lis = @$('.im-sorting-container li')
            newSO = lis.map( (i, e) -> {path: $(e).data('path'), direction: $(e).data("direction")}).get()
            @hideModal()
            @query.orderBy(newSO)

