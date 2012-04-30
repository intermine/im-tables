scope "intermine.results.table", (exporting) ->

    CELL_HTML = _.template """
        <div class="im-confinement">
            <input class="list-chooser" type="checkbox" style="display: none" data-obj-id="<%= id %>" 
                <% if (selected) { %>checked <% }; %>
                data-obj-type="<%= type %>">
            <% if (value == null) { %>
            <span class="null-value">no value</span>
            <% } else { %>
            <a class="im-cell-link" href="<%= base %><%= url %>"><%= value %></a>
            <% } %>
            <% if (field == 'url') { %>
            <a class="im-cell-link external" href="<%= value %>">link</a>
            <% } %>
        </div>
    """

    HIDDEN_FIELDS = ["class", "objectId"]

    exporting class Cell extends Backbone.View
        tagName: "td"
        className: "im-result-field"

        events:
            'click': 'activateChooser'

        initialize: ->
            @model.on "change:selected", (model, selected) =>
                @$el.toggleClass "active", selected
                @$('input').attr checked: selected
            @model.on "change:selectable", (model, selectable) =>
                @$('input').attr disabled: !selectable
            @options.query.on "start:list-creation", => @$('input').show()
            @options.query.on "stop:list-creation", =>
                @$('input').hide()
                @$el.removeClass "active"
                @model.set "selected", false

            @options.query.on "start:highlight:node", (node) =>
                if @options.node.toPathString() is node.toPathString()
                    @$el.addClass "im-highlight"
            @options.query.on "stop:highlight", => @$el.removeClass "im-highlight"

        render: ->
            html = CELL_HTML _.extend {}, @model.toJSON(), {value: @model.get(@options.field), field: @options.field}
            @$el.append(html).toggleClass(active: @model.get "selected")
            type = @model.get "type"
            id = @model.get "id"
            s = @options.query.service
            content = $ """
                <table class="im-item-details table table-condensed table-bordered">
                <colgroup>
                    <col class="im-item-field"/>
                    <col class="im-item-value"/>
                </colgroup>
                </table>
            """
            cellLink = @$el.find('.im-cell-link').first().popover
                placement: ->
                    table = cellLink.closest "table"
                    if cellLink.offset().left + 300 >= table.offset().left + table.width()
                        return "left"
                    else
                        return "right"
                title: type
                trigger: "hover"
                delay: {show: 500, hide: 100}
                content: ->
                    unless cellLink.data "content"
                        console.log "Fetching #{ id }"
                        s.findById type, id, (item) ->
                            for field, value of item when value and (field not in HIDDEN_FIELDS) and not value['objectId']
                                v = value + ""
                                v = if v.length > 100 then v.substring(0, 100) + "..." else v
                                content.append """
                                    <tr>
                                        <td>#{ field }</td>
                                        <td>#{ v }</td>
                                    </tr>
                                """
                            getLeaves = (o) ->
                                leaves = []
                                values = (leaf for name, leaf of o when name not in HIDDEN_FIELDS)
                                for x in values
                                    if x['objectId']
                                        leaves = leaves.concat(getLeaves(x))
                                    else
                                        leaves.push(x)
                                leaves
                                
                            for field, value of item when value and value['objectId']
                                values = getLeaves(value)
                                console.log values
                                content.append """
                                    <tr>
                                        <td>#{ field }</td>
                                        <td>#{ values.join ', ' }</td>
                                    </tr>
                                """

                            cellLink.data content: content
                            cellLink.popover("show")

                    return content
            this

        setWidth: (w) ->
            @$el.css width: w + "px"
            @$('.im-confinement').css width: (w - 5) + "px"
            this

        activateChooser: ->
            if @model.get "selectable"
                @model.set selected: !@model.get("selected") if @$('input').is ':visible'


    exporting class NullCell extends Cell
        initialize: ->
            @model = new Backbone.Model
                selected: false
                selectable: false
                value: null
                id: null
                url: null
                base: null
                type: null



