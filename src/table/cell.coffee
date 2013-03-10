# A set of functions of the signature:
#   (Backbone.Model, intermine.Query, jQuery) -> {value: string, field: string}
#
# Defining a formatter means that this function will be used to display data
# rather than the standard id being shown.

# TODO: move these into own class files

ChrLocFormatter = (model) ->
  id = model.get 'id'
  @$el.addClass 'chromosome-location'
  unless (model.has('start') and model.has('end') and model.has('chr'))
    model._formatter_promise ?= @options.query.service.findById 'Location', id
    model._formatter_promise.done (loc) ->
      model.set start: loc.start, end: loc.end, chr: loc.locatedOn.primaryIdentifier
  
  {start, end, chr} = model.toJSON()
  "#{chr}:#{start}-#{end}"

ChrLocFormatter.replaces = ['start', 'end', 'strand', 'locatedOn.primaryIdentifier']

SequenceFormatter = (model) ->
  id = model.get 'id'
  @$el.addClass 'dna-sequence'
  unless model.has('residues')
    model._formatter_promise ?= @options.query.service.findById 'Sequence', id
    model._formatter_promise.done (seq) -> model.set seq
  
  sequence = model.get( 'residues' ) || ''
  lines = []

  while sequence.length > 0
    line = sequence.slice 0, 80
    rest = sequence.slice 80
    lines.push line
    sequence = rest

  lines.join("\n")

PublicationFormatter = (model) ->
  id = model.get 'id'
  @$el.addClass 'publication'
  unless model.has('title') and model.has('firstAuthor') and model.has('year')
    model._formatter_promise ?= @options.query.service.findById 'Publication', id
    model._formatter_promise.done (pub) -> model.set pub

  {title, firstAuthor, year} = model.toJSON()
  "#{title} (#{firstAuthor}, #{year})"

PublicationFormatter.replaces = [ 'title', 'firstAuthor', 'year' ]

scope "intermine.results.formatters", {
    Manager: (model) ->
      id = model.get 'id'
      unless (model.has('title') and model.has('name'))
        model._formatter_promise ?= @options.query.service.findById 'Manager', id
        model._formatter_promise.done (manager) -> model.set manager
      
      data = _.defaults model.toJSON(), {title: '', name: ''}

      _.template "<%- title %> <%- name %>", data

    Sequence: SequenceFormatter
    Location: ChrLocFormatter
    Publication: PublicationFormatter

    Organism: (model, query, $cell) ->
      id = model.get 'id'
      @$el.addClass 'organism'
      templ = _.template """
        <span class="name"><%- shortName %></span>
      """
      unless (model.has('shortName') and model.has('taxonId'))
        model._formatter_promise ?= @options.query.service.findById 'Organism', id
        model._formatter_promise.done (org) ->
          model.set org

      data = _.extend {shortName: ''}, model.toJSON()
      templ data

}

scope "intermine.results.formatsets", {
  testmodel: { 'Manager.name': true },
  genomic: {
    'Location.*': true,
    'Organism.name': true,
    'Publication.title': true,
    'Sequence.residues': true
  }
}

scope "intermine.results", {
    getFormatter:   (model, type) ->
        formatter = null
        unless type?
          [model, type] = [model.model, model.getParent()?.getType()]
        type = type.name or type
        types = [type].concat model.getAncestorsOf(type)
        formatter or= intermine.results.formatters[t] for t in types
        return formatter

    shouldFormat: (path, formatSet) ->
      return false unless path.isAttribute()
      model = path.model
      formatSet ?= model.name
      cd = if path.isAttribute() then path.getParent().getType() else path.getType()
      fieldName = path.end.name
      formatterAvailable = intermine.results.getFormatter(path.model, cd)?

      return false unless formatterAvailable
      return true if fieldName is 'id'
      ancestors = [cd.name].concat path.model.getAncestorsOf cd.name
      formats = intermine.results.formatsets[formatSet] ? {}
      
      for a in ancestors
        return true if (formats["#{a}.*"] or formats["#{ a }.#{fieldName}"])
      return false

}

do ->

    # </div>
    CELL_HTML = _.template """
            <input class="list-chooser" type="checkbox" style="display: none" data-obj-id="<%= id %>" 
                <% if (selected) { %>checked <% }; %>
                data-obj-type="<%= _type %>">
            <% if (value == null) { %>
                <span class="null-value">no value</span>
            <% } else { %>
                <% if (url != null && url.match(/^http/)) { %>
                  <a class="im-cell-link" href="<%= url %>">
                    <% if (!url.match(window.location.origin)) { %>
                        <i class="icon-globe"></i>
                    <% } %>
                <% } else { %>
                  <a class="im-cell-link" href="<%= base %><%= url %>">
                <% } %>
                    <%- value %>
                </a>
            <% } %>
            <% if (field == 'url') { %>
                <a class="im-cell-link external" href="<%= value %>"><i class="icon-globe"></i>link</a>
            <% } %>
    """

    HIDDEN_FIELDS = ["class", "objectId"]

    class SubTable extends Backbone.View
        tagName: "td"
        className: "im-result-subtable"

        initialize: ->
            @query = @options.query
            @cellify = @options.cellify
            @path = @options.node
            subtable = @options.subtable
            @rows = subtable.rows
            @view = subtable.view
            @column = @query.getPathInfo(subtable.column)
            @query.on 'expand:subtables', (path) =>
                if path.toString() is @column.toString()
                    @$('.im-subtable').slideDown()
            @query.on 'collapse:subtables', (path) =>
                if path.toString() is @column.toString()
                    @$('.im-subtable').slideUp()

        getSummaryText: () ->
            if @column.isCollection()
                """#{ @rows.length } #{ @column.getType().name }s"""
            else
                # Single collapsed reference.
                if @rows.length is 0
                    # find the outer join:
                    level = if @query.isOuterJoined(@view[0])
                        @query.getPathInfo(@query.getOuterJoin(@view[0]))
                    else
                        @column
                    """No #{ level.getType().name }"""
                else
                    """#{@rows[0][0].value} (#{@rows[0][1 ..].map((c) -> c.value).join(', ')})"""

        render: () ->
            icon = if @rows.length > 0 then '<i class=icon-table></i>' else '<i class=icon-non-existent></i>'
            summary = $ """<span>#{ icon }&nbsp;#{ @getSummaryText() }</span>"""
            summary.addClass('im-subtable-summary').appendTo @$el
            t = $ '<table><thead><tr></tr></thead><tbody></tbody></table>'
            colRoot = @column.getType().name
            colStr = @column.toString()
            if @rows.length > 0
                for v in @view then do (v) =>
                    th = $ """<th>
                        <i class="#{intermine.css.headerIconRemove}"></i>
                        <span></span>
                    </th>"""
                    th.find('i').click (e) => @query.removeFromSelect v
                    path = @query.getPathInfo(v)
                    @column.getDisplayName (colName) =>
                        span = th.find('span')
                        if intermine.results.shouldFormat(path)
                            path = path.getParent()
                        path.getDisplayName (pathName) ->
                            if pathName.match(colName)
                                span.text pathName.replace(colName, '').replace(/^\s*>?\s*/, '')
                            else
                                span.text pathName.replace(/^[^>]*\s*>\s*/, '')
                    t.children('thead').children('tr').append th
                appendRow = (t, row) =>
                    tr = $ '<tr>'
                    w = @$el.width() / @view.length
                    for cell in row then do (tr, cell) =>
                      view = @cellify cell
                      if intermine.results.shouldFormat view.path
                        view.formatter = intermine.results.getFormatter view.path
                      else
                      tr.append view.el
                      view.render().setWidth w
                    t.children('tbody').append tr
                    null

                if @column.isCollection()
                    appendRow(t, row) for row in @rows
                else
                    appendRow(t, @rows[0]) # Odd hack to fix multiple repeated rows.


            t.addClass 'im-subtable table table-condensed table-striped'

            @$el.append t

            summary.css(cursor: 'pointer').click (e) =>
                e.stopPropagation()
                if t.is(':visible')
                    @query.trigger 'subtable:collapsed', @column
                else
                    @query.trigger 'subtable:expanded', @column
                t.slideToggle()

            this

        getUnits: () ->
            if @rows.length = 0
                @view.length
            else
                _.reduce(@rows[0], ((a, item) -> a + if item.view? then item.view.length else 1), 0)

        setWidth: (w) ->
            # @$el.css width: (w * @view.length) + "px"
            # @$('.im-cell-link').css "max-width": ((w * @view.length) - 5) + "px"
            this

    class Cell extends Backbone.View
        tagName: "td"
        className: "im-result-field"

        getUnits: () -> 1

        formatter: (model) -> model.escape @options.field

        events:
            'click': 'activateChooser'

        initialize: ->
            @model.on "change:selected", (model, selected) =>
                @$el.toggleClass "active", selected
                @$('input').attr checked: selected
            @model.on "change:selectable", (model, selectable) =>
                @$('input').attr disabled: !selectable
            @model.on 'change', @updateValue
            @options.query.on "start:list-creation", =>
                @$('input').show() if @model.get "selectable"
            @options.query.on "stop:list-creation", =>
                @$('input').hide()
                @$el.removeClass "active"
                @model.set "selected", false

            @options.query.on "start:highlight:node", (node) =>
                if @options.node?.toPathString() is node.toPathString()
                    @$el.addClass "im-highlight"
            @options.query.on "stop:highlight", => @$el.removeClass "im-highlight"

            field = @options.field
            path = @path = @options.node.append field
            @$el.addClass 'im-type-' + path.getType().toLowerCase()


          
        toField = (row) -> $(row).find('.im-field-name').text()

        sortTableByFieldName = (tbody) -> tbody.html _.sortBy tbody.children('tr').get(), toField

        {NUM_SEPARATOR, NUM_CHUNK_SIZE} = intermine.options
        numToStr = (n) -> intermine.utils.numToString n, NUM_SEPARATOR, NUM_CHUNK_SIZE
      
        # TODO: this should be its own view.
        getPopoverContent: ->
          return @model.cachedPopover if @model.cachedPopover?

          $throbber = $ """
            <div class="progress progress-info progress-striped active">
              <div class="bar" style="width: 100%"></div>
            </div>
          """
          itemDetails = $ """
              <table class="im-item-details table table-condensed table-bordered">
              <colgroup>
                  <col class="im-item-field"/>
                  <col class="im-item-value"/>
              </colgroup>
              </table>
          """
          relatedCounts = $ """
            <table class="table im-related-counts table-condensed"></table>
          """

          type = @model.get '_type'
          id = @model.get 'id'
          q = @options.query
          s = q.service
          root = s.root
          content = @make 'div'

          $throbber.appendTo content

          formatName = do (q) -> (field, row) ->
            p = q.model.getPathInfo "#{ type }.#{ field }"
            fv = row.find '.im-field-value'
            fv.addClass p.getType().toString().toLowerCase()
            p.getDisplayName().done (name) ->
              row.find('.im-field-name').text name.split(' > ').pop()
              sortTableByFieldName row.parent()

          types = [type].concat q.model.getAncestorsOf type

          itemDetails.addClass (t.toLowerCase() for t in types).join ' '
          
          ready = s.findById type, id, (item) ->
            $throbber.remove()
            itemDetails.prependTo content

            for field, value of item when value and (field not in HIDDEN_FIELDS) and not value['objectId']
              v = value + ""
              v = if v.length > 100 then v.substring(0, 100) + "..." else v
              row = $ """
                <tr>
                  <td class="im-field-name">#{ field }</td>
                  <td class="im-field-value #{field.toLowerCase()}">
                    #{ v }
                  </td>
                </tr>
              """
              formatName field, row
              itemDetails.append row

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
              row = $ """
                <tr>
                  <td class="im-field-name">#{ field }</td>
                  <td class="im-field-value #{ field.toLowerCase() }">
                    #{ values.join ', ' }
                  </td>
                </tr>
              """
              itemDetails.append row
              formatName field, row
          

          if conf = intermine.options.preview.count[root]?[type]
            for settings in conf
              if _.isObject settings
                {query, label} = settings
                q = intermine.utils.copy query
                intermine.utils.walk q, (o, k, v) -> o[k] = id if v is '{{ID}}'
              else
                label = settings
                q = select: settings + '.id', from: type, where: {id: id}
              counted = s.count(q).done do (label) -> (c) ->
                $throbber.remove()
                relatedCounts.appendTo content
                relatedCounts.append """
                  <tr>
                    <td>#{ label }:</td> <td class="im-count">#{ numToStr c }</td>
                  </tr>
                """
              ready = ready.then -> counted

          @model.cachedPopover = [content, ready]
          

        setupPreviewOverlay: ->
          @$el.popover
            container: 'body'
            html: true
            placement: (popover) =>
                $(popover).addClass 'im-cell-preview bootstrap'
                table = @$el.closest "table"
                {left} = @$el.offset()
                w = @$el.width()
                if left + w + 400 <= table.offset().left + table.width()
                    return 'right'
                if table.offset().left <= left - 400
                    return 'left'
                else
                    return "bottom"
            title: @model.get '_type'
            trigger: "hover"
            delay: {show: 500, hide: 100}
            content: =>
                unless @content
                  [@content, ready] = @getPopoverContent()
                  ready.done => @$el.popover 'show'

                @content


        updateValue: => @$('.im-cell-link').html @formatter(@model)

        render: ->
            id = @model.get "id"
            field = @options.field
            data =
              value: @model.get field
              field: field

            _.defaults data, @model.toJSON(), {'_type': ''}
            html = CELL_HTML data

            @$el.append(html)
                .toggleClass(active: @model.get "selected")

            @updateValue()

            @setupPreviewOverlay() if id?
            this

        setWidth: (w) ->
          #@$el.css width: w + "px"
          #  @$('.im-cell-link').css "max-width": (w - 5) + "px"
          this

        activateChooser: ->
            if @model.get "selectable"
                @model.set selected: !@model.get("selected") if @$('input').is ':visible'

    class NullCell extends Cell
        setupPreviewOverlay: ->

        initialize: ->
            @model = new Backbone.Model
                selected: false
                selectable: false
                value: null
                id: null
                url: null
                base: null
                _type: null
            super()

    scope "intermine.results.table", {NullCell, SubTable, Cell}

