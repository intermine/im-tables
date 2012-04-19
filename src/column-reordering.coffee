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
                console.log "Unpromoted", i, e
                $elem = $(e)
                $elem.data target: @$($elem.data("target"))

            @$('.modal').modal
                show: false
            this

        events:
            'click a.im-reorderer': 'showModal'
            'click .btn-cancel': 'hideModel'
            'click .btn-primary': 'changeOrder'
            'click .nav-tabs li a': 'changeTab'
            'click .im-soe i.icon-remove-circle': 'removeSortOrder'
            'click .im-soe i.icon-arrow-up': 'sortCol'
            'click .im-soe i.icon-arrow-down': 'sortCol'

        changeTab: (e) ->
            console.log "Obj?", $(e.target).data("target")
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
            $(e.target).toggleClass "icon-arrow-up icon-arrow-down"

        soTemplate: _.template """
            <li class="im-reorderable breadcrumb im-soe" 
                data-path="<%- path %> data-direction=<% direction %>">
                <% if (direction === 'ASC') { %>
                    <i class="icon-arrow-up"></i>
                <% } else { %>
                    <i class="icon-arrow-down"></i>
                <% } %>
                <%- path %>
                <i class="icon-remove-circle pull-right"></i>
            </li>
        """

        possibleSortOptionTemplate: _.template """
            <li class="im-reorderable breadcrumb" data-path="<%- path %>">
                <%- path %>
            </li>
        """

        removeSortOrder: (e) ->
            $elem = $(e.target).parent()
            path = $elem.data "path"
            $elem.remove()
            possibilities = @$ '.im-sorting-container-possibilities'
            psoe = $ @possibleSortOptionTemplate path: path
            psoe.draggable
                revert: "invalid"
                revertDuration: 100
            possibilities.append psoe

        initSorting: =>
            container = @$ '.im-sorting-container'
            container.empty()
            for so, i in (@query.sortOrder or [])
                container.append @soTemplate so

            possibilities = @$ '.im-sorting-container-possibilities'
            possibilities.empty()
            for v in @query.views when not @query.getSortDirection(v)
                possibilities.append @possibleSortOptionTemplate path: v

            possibilities.find("li").draggable
                revert: "invalid"
                revertDuration: 100

            container.sortable().droppable
                drop: (event, ui) =>
                    path = $(ui.draggable).data("path")
                    $(ui.draggable).remove()
                    container.append @soTemplate path: path, direction: "ASC"

        hideModel: ->
            @$('.modal').modal('hide')
            @initOrdering()
            @initSorting()

        showModal: ->
            @$('.modal').modal('show')

        changeOrder: (e) ->
            lis = @$('.im-reordering-container li')
            newView = lis.map( (i, e) -> $(e).data('path')).get()
            @$('.modal').modal('hide')
            @query.select(newView)
