do ->

  HIDDEN_FIELDS = ["class", "objectId"]

  getLeaves = (o) ->
    leaves = []
    values = (leaf for name, leaf of o when name not in HIDDEN_FIELDS)
    for x in values
      if x['objectId']
        leaves = leaves.concat(getLeaves(x))
      else
        leaves.push(x)
    leaves

  toField = (row) -> $(row).find('.im-field-name').text()

  sortTableByFieldName = (tbody) -> tbody.html _.sortBy tbody.children('tr').get(), toField

  {NUM_SEPARATOR, NUM_CHUNK_SIZE, CellCutoff} = intermine.options

  numToStr = (n) -> intermine.utils.numToString n, NUM_SEPARATOR, NUM_CHUNK_SIZE

  class Preview extends intermine.views.ItemView

    className: 'im-cell-preview-inner'


    ITEM_ROW = _.template """
      <tr>
        <td class="im-field-name"><%= field %></td>
        <td class="im-field-value <%= field.toLowerCase() %>">
          <%- value %>
          <span class="im-overspill"><%- valueOverspill %></span>
          <% if (tooLong) { %>
            <a href="#" class="im-too-long">
              <span class="im-ellipsis">...</span>
              <i class="#{ intermine.icons.More }"></i>
            </a>
          <% } %>
        </td>
      </tr>
    """

    THROBBER = """
      <div class="progress progress-info progress-striped active">
        <div class="bar" style="width: 100%"></div>
      </div>
    """

    ITEMS = """
      <table class="im-item-details table table-condensed table-bordered">
      <colgroup>
          <col class="im-item-field"/>
          <col class="im-item-value"/>
      </colgroup>
      </table>
    """

    RELATIONS = """
      <table class="table im-related-counts table-condensed"></table>
    """

    RELATION = _.template """
      <tr>
        <td><%- label %></td> <td class="im-count"><%= count %></td>
      </tr>
    """

    REFERENCE = _.template """
      <tr>
        <td class="im-field-name"><%= field %></td>
        <td class="im-field-value <%= field.toLowerCase() %>">
           <%- values.join(', ') %>
        </td>
      </tr>
    """
    
    events:
      'click .im-too-long': 'revealLongField'

    revealLongField: (e) ->
      e?.preventDefault()
      e?.stopPropagation()
      $tooLong = $ e.currentTarget
      $overSpill = $tooLong.siblings '.im-overspill'
      $tooLong.remove()
      $overSpill.show()

    template: _.template THROBBER

    initialize: ->
      super arguments...
      @on 'rendered', @insertRows, @

    formatName: (field, row) ->
      type = @model.get('type')
      p = @options.schema.getPathInfo "#{ type }.#{ field }"
      fv = row.find '.im-field-value'
      fv.addClass p.getType().toString().toLowerCase()
      p.getDisplayName().done (name) =>
        row.find('.im-field-name').text name.split(' > ').pop()
        sortTableByFieldName row.parent()
        @trigger 'ready'


    handleItem: (item) =>
      table = @itemDetails

      # Attribute fields.
      for field, v of item when v and (field not in HIDDEN_FIELDS) and not v['objectId']
        value = v + ''
        tooLong = value.length > CellCutoff
        snipPoint = value.indexOf ' ', CellCutoff * 0.9 # Try and break on whitespace
        snipPoint = CellCutoff if snipPoint is -1
        value = if tooLong then value.substring(0, snipPoint) else value
        valueOverspill = (v + '').substring(snipPoint)
        row = $ ITEM_ROW {field, value, tooLong, valueOverspill}

        @formatName field, row
        table.append row
          
      # Reference fields.
      for field, value of item when value and value['objectId']
        values = getLeaves(value)
        row = $ REFERENCE {field, values}

        @formatName field, row
        table.append row

    fillRelationsTable: (table) ->
      type = @model.get 'type'
      {service: {root}} = @options

      for settings in (intermine.options.preview.count[root]?[type] ? [])
        @handleRelationCount settings

    handleRelationCount: (settings) ->
      table = @relatedCounts
      {type, id} = @model.toJSON()

      if _.isObject settings
        {query, label} = settings
        counter = intermine.utils.copy query
        intermine.utils.walk counter, (o, k, v) -> o[k] = id if v is '{{ID}}'
      else
        label = settings
        counter = select: settings + '.id', from: type, where: {id: id}

      @options.service.count(counter).done (c) -> table.append RELATION {label, count: numToStr c}

    fillItemTable: ->
      {type, id} = @model.toJSON()
      {schema, service} = @options
      table = @itemDetails

      types = [type].concat schema.getAncestorsOf type
      table.addClass (t.toLowerCase() for t in types).join ' '

      service.findById type, id, @handleItem

    insertRows: ->

      @itemDetails = $ ITEMS
      @relatedCounts = $ RELATIONS

      ready = @fillItemTable()

      for promise in @fillRelationsTable()
        ready = ready.then -> promise

      ready.done =>
        @$el.empty().append(@itemDetails).append(@relatedCounts)
        @trigger 'ready'

      ready.fail (err) =>
        @renderError err
        @trigger 'ready'

        
  scope 'intermine.table.cell', {Preview}
          




