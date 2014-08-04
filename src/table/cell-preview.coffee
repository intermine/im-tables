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

  sortByName = (model) -> model.get 'name'

  toField = (row) -> $(row).find('.im-field-name').text()

  sortTableByFieldName = (tbody) -> tbody.html _.sortBy tbody.children('tr').get(), toField

  {NUM_SEPARATOR, NUM_CHUNK_SIZE, CellCutoff} = intermine.options

  numToStr = (n) -> intermine.utils.numToString n, NUM_SEPARATOR, NUM_CHUNK_SIZE

  class ItemDetails extends intermine.views.ItemView

    ITEMS = """
      <table class="im-item-details table table-condensed table-bordered">
      <colgroup>
          <col class="im-item-field"/>
          <col class="im-item-value"/>
      </colgroup>
      </table>
    """

    REFERENCE = _.template """
      <tr>
        <td class="im-field-name"><%= name %></td>
        <td class="im-field-value <%= field.toLowerCase() %>">
           <%- values.join(', ') %>
        </td>
      </tr>
    """

    ATTR = _.template """
      <tr>
        <td class="im-field-name"><%= name %></td>
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

    initialize: ->
      super
      @collection.on 'add', @render, @

    template: ->
      table = $ ITEMS
      @collection.each (details) ->
        f = if details.get('fieldType') is 'ATTR' then ATTR else REFERENCE
        table.append f details.toJSON()
      return table

    events:
      'click .im-too-long': 'revealLongField'

    revealLongField: (e) ->
      e?.preventDefault()
      e?.stopPropagation()
      $tooLong = $ e.currentTarget
      $overSpill = $tooLong.siblings '.im-overspill'
      $tooLong.remove()
      $overSpill.show()

  class ReferenceCounts extends intermine.views.ItemView

    RELATIONS = """
      <ul class="im-related-counts"></ul>
    """

    RELATION = _.template """
      <li class="im-relation">
        <span class="pull-left"><%- name %></span>
        <span class="pull-right im-count"><%= count %></span>
      </li>
    """
     
    initialize: ->
      super
      @collection.on 'add', @render, @

    template: ->
      relations = $ RELATIONS
      @collection.each (details) ->
        data = details.toJSON()
        data.count = numToStr data.count
        relations.append RELATION data
      return relations

  class Preview extends intermine.views.ItemView

    className: 'im-cell-preview-inner'

    THROBBER = """
      <div class="progress progress-info progress-striped active">
        <div class="bar" style="width: 100%"></div>
      </div>
    """

    initialize: (@options = {}) ->
      super arguments...
      @fieldDetails = new Backbone.Collection
      @fieldDetails.model = Backbone.Model
      @fieldDetails.comparator = sortByName
      @fieldDetails.on 'add', @render, @
      @referenceFields = new Backbone.Collection
      @referenceFields.model = Backbone.Model
      @referenceFields.comparator = sortByName
      @referenceFields.on 'add', @render, @

      @itemDetailsTable = new ItemDetails collection: @fieldDetails
      @referenceCounts = new ReferenceCounts collection: @referenceFields

    remove: ->
      @fieldDetails.off()
      @fieldDetails.reset()
      @referenceFields.off()
      @referenceFields.reset()
      @itemDetailsTable.remove()
      @referenceCounts.remove()
      super arguments...

    # Return a promise for the name
    formatName: (field) ->
      p = null
      for t in @model.get('type').split ','
        p ?= try
          @options.schema.getPathInfo "#{ t }.#{ field }"
        catch e
          null
      throw new Error("invalid field (#{ field }) for #{ @model.get('type') }") unless p
      return p.getDisplayName().then (name) -> name.split(' > ').pop()

    # TODO: We should probably make sure we add these classes to the method.
    # fv = row.find '.im-field-value'
    # fv.addClass p.getType().toString().toLowerCase()
    # p.getDisplayName().done (name) =>
    #   row.find('.im-field-name').text name.split(' > ').pop()
    #   sortTableByFieldName row.parent()
    #   @trigger 'ready'

    # Reads values from the returned items and adds details objects to the 
    # fieldDetails and referenceFields collections, avoiding duplicates.
    handleItem: (item) =>
      field = null
      byField = (model) -> model.get('field') is field

      # Attribute fields.
      for field, v of item when v and (field not in HIDDEN_FIELDS) and not v['objectId']
        if not @fieldDetails.find(byField) then do (field, v) =>
          value = "#{ v }"
          tooLong = value.length > CellCutoff
          snipPoint = value.indexOf ' ', CellCutoff * 0.9 # Try and break on whitespace
          snipPoint = CellCutoff if snipPoint is -1
          value = if tooLong then value.substring(0, snipPoint) else value
          valueOverspill = (v + '').substring(snipPoint)
          details = {fieldType: 'ATTR', field, value, tooLong, valueOverspill}
          @formatName(field).then (name) =>
            details.name = name
            @fieldDetails.add details
        
      # Reference fields.
      for field, value of item when value and value['objectId']
        if not @fieldDetails.find(byField) then do (field, value) =>
          values = getLeaves(value)
          details = {fieldType: 'REF', field, values}
          @formatName(field).then (name) =>
            details.name = name
            @fieldDetails.add details

      this

    fetchData: ->
      {type, id} = @model.toJSON()
      {schema, service} = @options
      types = type.split ','

      fetches = for t in type.split ','
        service.findById t, id, @handleItem

      fetches.concat(@getRelationCounts()).reduce (p1, p2) -> p1.then -> p2

    getRelationCounts: ->
      types = @model.get 'type'
      root = @options.service.root

      countSets = for type in types.split(',')
        for settings in (intermine.options.preview.count[root]?[type] ? [])
          @getRelationCount settings
      countSets.reduce ((a, s) -> a.concat(s)), []

    # TODO - move into fetch data. correct the model!
    getRelationCount: (settings) ->
      table = @relatedCounts
      {type, id} = @model.toJSON()

      if _.isObject settings
        {query, label} = settings
        counter = intermine.utils.copy query
        intermine.utils.walk counter, (o, k, v) -> o[k] = id if v is '{{ID}}'
      else
        label = settings
        counter = select: settings + '.id', from: type, where: {id: id}

      @options.service.count(counter).then (c) => @referenceFields.add {name: label, count: c}

    template: (data) ->

      frag = document.createDocumentFragment()
      itemDetailsTable = @itemDetailsTable.el

      frag.appendChild itemDetailsTable

      if @referenceFields.length
        h4 = document.createElement('h4')
        h4.text = intermine.messages.cell.RelatedItems
        frag.appendChild h4
        relationCountTable = @referenceCounts.el
        frag.appendChild relationCountTable

      @fetching ?= @fetchData()

      @itemDetailsTable.render()
      @referenceCounts.render()

      return frag
        
  scope 'intermine.table.cell', {Preview}
