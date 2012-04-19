scope "intermine.results.table", (exporting) ->

    CELL_HTML = _.template """
        <input class="list-chooser" type="checkbox" style="display: none" data-obj-id="<%= id %>" 
               <% if (selected) { %>checked <% }; %>
               data-obj-type="<%= type %>">
        <% if (value == null) { %>
         <span class="null-value">no value</span>
        <% } else { %>
         <a class="im-cell-link" href="<%= base %><%= url %>"><%= value %></a>
        <% } %>
    """

    HIDDEN_FIELDS = ["class", "objectId"]

    exporting class Cell extends Backbone.View
        tagName: "td"
        className: "im-result-field"

        events:
            'click': 'activateChooser'

        initialize: ->
            @model.on "change:selected", =>
                s = @model.get "selected"
                @$el.toggleClass "active", s
                @$('input').attr checked: s
            @model.on "change:selectable", =>
                s = @model.get "selectable"
                @$('input').attr disabled: s
            @options.query.on "start:list-creation", => @$('input').show()
            @options.query.on "stop:list-creation", =>
                @$('input').hide()
                @$el.removeClass "active"
                @model.set "selected", false

        render: ->
            html = CELL_HTML _.extend {}, @model.toJSON(), {value: @model.get(@options.field)}
            @$el.html(html).toggleClass(active: @model.get "selected")
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
            cellLink = @$el.find('.im-cell-link').popover
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
                            for field, value of item when value and value['objectId']
                                values = (v for f, v of value when f not in HIDDEN_FIELDS)
                                content.append """
                                    <tr>
                                        <td>#{ field }</td>
                                        <td>#{ values.join '' }</td>
                                    </tr>
                                """

                            cellLink.data content: content
                            cellLink.popover("show")

                    return content
            this

        activateChooser: ->
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



