class BooleanFacet extends PieFacet

  initialize: ->
    super
    if @items.length is 2
      @items.on 'change:selected', (x, selected) =>
        @items.each (y) -> y.set(selected: false) if (selected and x isnt y)
        someAreSelected = @items.any((item) -> !! item.get "selected")
        @$('.im-filtering.btn').attr "disabled", !someAreSelected

  filterControls: ''

  initFilter: ->

  buttons: -> """
    <button type="submit" class="btn btn-primary im-filtering im-filter-in" disabled>Filter</button>
    <button class="btn btn-cancel im-filtering" disabled>Reset</button>
  """

