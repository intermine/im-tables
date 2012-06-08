scope "intermine.query.results.table", (exporting) ->

    exporting class ColumnOrderer extends Backbone.View
        
        initialize: (@query) ->
            @query.on "change:sortorder", @initSorting

        template: _.template """
            <a class="btn btn-large im-reorderer">
                <i class="icon-move"></i>
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
        """

        viewTemplate: _.template """
            <li class="im-reorderable breadcrumb" data-col-idx="<%= idx %>" data-path="<%- path %>">
                <i class="icon-move"></i>
                <%- displayName %>
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
            for v, i in @query.views
                moveableView = $ @viewTemplate(idx: i, displayName: v, path: v)
                colContainer.append moveableView
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
            newView = lis.map( (i, e) -> $(e).data('path')).get()
            @$('.modal').modal('hide')
            @query.select(newView)

        changeSorting: (e) ->
            lis = @$('.im-sorting-container li')
            newSO = lis.map( (i, e) -> {path: $(e).data('path'), direction: $(e).data("direction")}).get()
            @$('.modal').modal('hide')
            @query.orderBy(newSO)

