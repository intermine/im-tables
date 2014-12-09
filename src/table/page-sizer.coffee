define 'table/page-sizer', ->

  class PageSizer extends Backbone.View

    tagName: 'form'
    className: "im-page-sizer form-horizontal"
    sizes: [[10], [25], [50], [100], [250]] # [0, 'All']]

    initialize: ->
      if size = @model.get('size')
        unless _.include (s[0] for s in @sizes), size
          @sizes = [[size, size]].concat @sizes # assign, don't mutate
      @listenTo @model, 'change:size', => @$('select').val @model.get 'size'

    events: { 'change select': 'changePageSize' }

    changePageSize: (evt) ->
      input = $(evt.target)
      size = parseInt(input.val(), 10)
      oldSize = @model.get 'size'
      applyChange = =>
        @model.set {size}
      rollback = (e) =>
        input.val oldSize
      @handlePageSizeSelection(size).then applyChange, rollback

    template: _.template """
      <label>
        <span class="im-only-widescreen">Rows per page:</span>
        <select class="span" title="Rows per page">
          <% sizes.forEach(function (s) { %>
            <option value="<%= s[0] %>" <%= (s[0] === size) && 'selected' %>>
              <%= s[1] || s[0] %>
            </option>
          <% }); %>
        </select>
      </label>
    """

    render: ->
      frag = $ document.createDocumentFragment()
      size = @model.get 'size'
      frag.append @template _.extend @model.toJSON(), {@sizes}
      @$el.html frag

      this

    pageSizeFeasibilityThreshold: 250

    # Check if the given size could be considered problematic
    #
    # A size if problematic if it is above the preset threshold, or if it 
    # is a request for all results, and we know that the count is large.
    # @param size The size to assess.
    aboveSizeThreshold: (size) ->
      if size and size >= @pageSizeFeasibilityThreshold
        return true
      if not size # falsy values null, 0 and '' are treated as all
        total = @model.get('count')
        return total >= @pageSizeFeasibilityThreshold
      return false

    # If the new page size is potentially problematic, then check with the user
    # first, rolling back if they see sense. Otherwise, change the page size
    # without user interaction.
    # @param size the requested page size.
    handlePageSizeSelection: (size) ->
      def = new jQuery.Deferred
      if @aboveSizeThreshold size
        $really = $ intermine.snippets.table.LargeTableDisuader
        $really.find('.btn-primary').click -> def.resolve()
        $really.find('.im-alternative-action').click (e) -> def.reject()
        $really.find('.btn').click -> $really.modal('hide')
        $really.on 'hidden', ->
          $really.remove()
          def.reject() # if not explicitly done so.
        $really.appendTo(@el).modal().modal('show')
      else
        def.resolve()

      return def.promise()
