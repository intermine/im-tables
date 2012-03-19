namespace "intermine.results.table", (public) ->

    CELL_HTML = _.template """
        <input class="list-chooser" type="checkbox" style="display: none" data-obj-id="<%= id %>" 
               <% if (selected) { %>checked <% }; %>
               data-obj-type="<%= type %>">
        <% if (value == null) { %>
         <span class="null-value">no value</span>
        <% } else { %>
         <a href="<%= base %><%= url %>"><%= value %></a>
        <% } %>
    """


    public class Cell extends Backbone.View
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
            this

        activateChooser: ->
            @model.set selected: !@model.get("selected") if @$('input').is ':visible'

    public class NullCell extends Cell
        initialize: ->
            @model = new Backbone.Model
                selected: false
                selectable: false
                value: null
                id: null
                url: null
                base: null
                type: null



