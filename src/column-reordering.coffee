scope "intermine.query.results.table", (exporting) ->

    class OuterJoinGroup extends Backbone.View
        tagName: 'li'
        className: 'im-reorderable breadcrumb'

        initialize: (@query, @ojg, views, @indices) ->
            paths = (@query.getPathInfo(v) for v in views)
            @nodes = _.groupBy(paths, (p) -> p.getParent().toString())

        getViews: () ->
            ret = []
            for key in _.sortBy(_.keys(@nodes), (k) -> k.length) then do (key) =>
                node = @nodes[key]
                for p in node
                    ret.push p.toString()
            ret

        render: () ->
            @$el.append '<i class="icon-reorder pull-right"></i>'
            h4 = $ '<h4>'
            @$el.append h4
            @ojg.getDisplayName (name) -> h4.text name
            @$el.data 'indices', @indices
            @$el.data 'path', @ojg.toString()
            ul = $ '<ul>'
            for key in _.sortBy(_.keys(@nodes), (k) -> k.length) then do (key) =>
                paths = @nodes[key]
                for p in paths then do (p) =>
                    li = $ '<li class="im-outer-joined-path">'
                    ul.append li
                    p.getDisplayName (name) =>
                        @ojg.getDisplayName (ojname) ->
                            li.text name.replace(ojname, '').replace(/^\s*>?\s*/, '')
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
        className: "form node-adder input-append"

        handleSubmission: (e) =>
            e.preventDefault()
            e.stopPropagation()
            newPath = @$('input').val()
            @query.trigger 'column-orderer:selected', newPath
            @$('.btn-chooser').button('toggle')
            @$pathfinder?.remove()
            @$pathfinder = null

        render: () ->
            super()
            @$('input').hide()
            this

    exporting class ColumnOrderer extends Backbone.View
        
        initialize: (@query) ->
            @query.on "change:sortorder", @initSorting
            @query.on 'column-orderer:selected', (path) =>
                if @query.isOuterJoined(path)
                    ojg = _.last(
                        _.sortBy(
                            _.filter(
                                _.values(@ojgs),
                                (ojg) -> !!path.match(ojg.ojg.toString())
                            ),
                            (ojg) -> ojg.ojg.descriptors.length
                        ))
                    ojg.addPath(path)
                else
                    moveableView = $ @viewTemplate path: path, displayName: path, idx: ''
                    @query.getPathInfo(path).getDisplayName (name) ->
                        moveableView.find('.im-display-name').text name
                    moveableView.appendTo @$ '.im-reordering-container'

        template: _.template """
            <a class="btn btn-large im-reorderer">
                <i class="icon-wrench"></i>
                Manage Columns
            </a>
            <div class="modal fade im-col-order-dialog">
                <div class="modal-header">
                    <a class="close" data-dismiss="modal">close</a>
                    <h3>Manage Columns</a>
                </div>
                <div class="modal-body">
                    <ul class="nav nav-tabs">
                        <li class="active"><a data-target=".im-reordering" data-toggle="tab">Re-Order Columns</a></li>
                        <li><a data-target=".im-sorting" data-toggle="tab">Re-Sort Columns</a></li>
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
            </div>
            <div style="clear: both;"></div>
        """

        viewTemplate: _.template """
            <li class="im-reorderable breadcrumb" data-col-idx="<%= idx %>" data-path="<%- path %>">
                <i class="icon-reorder pull-right""></i>
                <h4 class="im-display-name"><%- displayName %></span>
            </li>
        """

        render: ->
            @$el.append @template()
            colContainer = @initOrdering()
            colContainer.sortable()
            @initSorting()

            @$('.nav-tabs li a').each (i, e) =>
                $elem = $(e)
                $elem.data target: @$($elem.data("target"))

            @$('.modal').modal
                show: false
            this

        events:
            'click a.im-reorderer': 'showModal'
            'click .btn-cancel': 'hideModel'
            'click .btn-primary': 'applyChanges'
            'click .nav-tabs li a': 'changeTab'
            'click .im-soe i.im-remove-soe': 'removeSortOrder'
            'click .im-add-soe': 'addSortOrder'
            'click .im-sort-direction': 'sortCol'

        changeTab: (e) ->
            $(e.target).tab("show")

        initOrdering: ->
            colContainer = @$ '.im-reordering-container'
            colContainer.empty()
            @ojgs = {}
            for v, i in @query.views then do (v, i) =>
                if @query.isOuterJoined(v)
                    # find oj closest to root
                    pi = @query.getPathInfo(v)
                    oj = if @query.joins[pi.toString()] is 'OUTER' then pi else null
                    while !pi?.isRoot()
                        pi = pi.getParent()
                        oj = if @query.joins[pi.toString()] is 'OUTER' then pi else oj
                    ojStr = oj.toString()
                    unless @ojgs[ojStr] # done this already.
                        vandi = ([v, i] for v, i in @query.views when (v.match(ojStr)))
                        views = (x[0] for x in vandi)
                        indices = (x[1] for x in vandi)
                        ojg = new OuterJoinGroup(@query, oj, views, indices)
                        @ojgs[ojStr] = ojg
                        moveableView = ojg.render().el
                else
                    moveableView = $ @viewTemplate(idx: i, displayName: v, path: v)
                    @query.getPathInfo(v).getDisplayName (name) ->
                        moveableView.find('.im-display-name').text name

                colContainer.append moveableView
            nodeAdder = @$ '.node-adder'
            ca = new ColumnAdder(@query)
            nodeAdder.empty().append ca.render().el # TODO: make this work nicely in the modal.
            colContainer

        sortCol: (e) ->
            $elem = $(e.target).parent()
            newDirection = if $elem.data("direction") is "ASC" then "DESC" else "ASC"
            $elem.data direction: newDirection
            $(e.target).toggleClass "asc desc"

        soTemplate: _.template """
            <li class="im-reorderable breadcrumb im-soe" 
                data-path="<%- path %>" data-direction="<%- direction %>">
                <% if (direction === 'ASC') { %>
                    <span class="im-sort-direction asc"></span>
                <% } else { %>
                    <span class="im-sort-direction desc"></span>
                <% } %>
                <%- path %>
                <i class="icon-minus pull-right im-remove-soe" title="Remove this column from the sort order"></i>
            </li>
        """

        possibleSortOptionTemplate: _.template """
            <li class="im-reorderable breadcrumb" data-path="<%- path %>">
                <%- path %>
                <i class="icon-plus pull-right im-add-soe" title="Add this column to the sort order"></i>
            </li>
        """

        removeSortOrder: (e) ->
            $elem = $(e.target).parent()
            path = $elem.data "path"
            $elem.find('.im-remove-soe').tooltip("hide")
            $elem.remove()
            possibilities = @$ '.im-sorting-container-possibilities'
            psoe = $ @possibleSortOptionTemplate path: path
            psoe.draggable
                revert: "invalid"
                revertDuration: 100
            psoe.find(".im-add-soe").tooltip()
            possibilities.append psoe

        addSortOrder: (e) ->
            $elem = $(e.target).parent()
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
            soe.addClass("numeric") if @query.getPathInfo(so.path).getType() in intermine.Model.NUMERIC_TYPES
            soe.find('.im-remove-soe').tooltip()
            soe

        initSorting: =>
            container = @$ '.im-sorting-container'
            container.empty().append(@sortingPlaceholder)
            for so, i in (@query.sortOrder or [])
                container.append @makeSortOrderElem(so)

            possibilities = @$ '.im-sorting-container-possibilities'
            possibilities.empty()
            for v in @query.views when not @query.getSortDirection(v) and not @query.isOuterJoined(v)
                possibilities.append @possibleSortOptionTemplate path: v

            for n in @query.getQueryNodes() when not @query.isOuterJoined n.toPathString()
                for cn in n.getChildNodes() when cn.isAttribute() and cn.toPathString() not in @query.views
                    possibilities.append @possibleSortOptionTemplate path: cn.toPathString()

            possibilities.find("li").draggable
                revert: "invalid"
                revertDuration: 100
            possibilities.find(".im-add-soe").tooltip()

            container.sortable().droppable
                drop: (event, ui) =>
                    path = $(ui.draggable).data("path")
                    $(ui.draggable).remove()
                    container.append @makeSortOrderElem path: path, direction: "ASC"

        hideModel: ->
            @$('.modal').modal('hide')
            @initOrdering()
            @initSorting()

        showModal: ->
            @$('.modal').modal('show')

        applyChanges: (e) ->
            if @$('.im-reordering').is('.active')
                @changeOrder(e)
            else
                @changeSorting(e)

        changeOrder: (e) ->
            lis = @$('.im-reordering-container li')
            paths = lis.map( (i, e) -> $(e).data('path')).get()
            newViews = []
            for p in paths
                pi = @query.getPathInfo(p)
                if pi.isAttribute()
                    newViews.push p
                else
                    console.log(p, @ojgs)
                    ojg = @ojgs[p]
                    for v in ojg.getViews()
                        newViews.push(v)

            @$('.modal').modal('hide')
            @query.select(newViews)

        changeSorting: (e) ->
            lis = @$('.im-sorting-container li')
            newSO = lis.map( (i, e) -> {path: $(e).data('path'), direction: $(e).data("direction")}).get()
            @$('.modal').modal('hide')
            @query.orderBy(newSO)

