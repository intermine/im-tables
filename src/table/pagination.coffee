define 'table/pagination', ->

  class Pagination extends Backbone.View

    initialize: ->
      @listenTo @model, 'change:start change:count', @render

    render: ->
      {start, size, count} = @model.toJSON()
      data =
        gotoStart: if start is 0 then 'active' else ''
        goFiveBack: if start < (5 * size) then 'active' else ''
        goOneBack: if start < size then 'active' else ''
        gotoEnd: if start >= (count - size) then 'active' else ''
        goFiveForward: if start >= (count - 6 * size) then 'active' else ''
        goOneForward: if start >= (count - 2 * size) then 'active' else ''

      @$el.html intermine.snippets.table.Pagination data
      @$('li').tooltip placement: 'top'

    events:
      'submit .im-page-form': 'pageFormSubmit'
      'click .im-pagination-button': 'pageButtonClick'
      'click .im-current-page a': 'clickCurrentPage'

    getMaxPage: () ->
      {count, size} = @model.toJSON()
      correction = if count % size is 0 then -1 else 0
      Math.floor(count / size) + correction

    goTo: (start) ->
      console.debug 'Going to', start
      @model.set start: start

    goToPage: (page) -> @model.set start: (page * @model.get('size'))

    goBack: (pages) ->
      {start, size} = @model.toJSON()
      @goTo Math.max 0, start - (pages * size)

    goForward: (pages) ->
      {start, size} = @model.toJSON()
      @goTo Math.min @getMaxPage() * size, start + (pages * size)

    clickCurrentPage: ->
      size = @model.get 'size'
      total = @model.get 'count'
      return if size >= total
      currentPageButton.hide()
      $pagination.find('form').show()

    pageButtonClick: (e) ->
      $elem = $(e.target)
      unless $elem.parent().is('.active') # Here active means "where we are"
        switch $elem.data("goto")
          when "start"        then @goTo 0
          when "prev"         then @goBack 1
          when "fast-rewind"  then @goBack 5
          when "next"         then @goForward 1
          when "fast-forward" then @goForward 5
          when "end"          then @goToPage @getMaxPage()

    pageFormSubmit: (e) ->
        e.stopPropagation()
        e.preventDefault()
        pageForm = @$('.im-page-form')
        centre = @$('.im-current-page')
        inp = pageForm.find('input')
        if inp.size()
            destination = inp.val().replace(/\s*/g, "")
          if destination.match /^\d+$/
                newSelectorVal = Math.min @getMaxPage(), Math.max(parseInt(destination) - 1, 0)
                @table.goToPage newSelectorVal
                centre.find('a').show()
                pageForm.hide()
          else
                pageForm.find('.control-group').addClass 'error'
                inp.val ''
                inp.attr placeholder: "1 .. #{ @getMaxPage() + 1 }"
