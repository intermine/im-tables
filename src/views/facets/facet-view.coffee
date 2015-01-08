Event = require '../../event'
CoreView = require '../../core-view'
Options = require '../../options'
Templates = require '../../templates'

class FacetTitle extends CoreView

  tagName: 'dt'

  initialize: ->
    super
    @listenTo @model, 'change', @reRender # props: got, pathName
    @listenTo @state, 'change', @reRender # props: open
  
  template: Templates.template 'facet_title'

module.exports = class FacetView extends CoreView

    tagName: "dl"

    fetchSummary: -> # overwritten by constructor.

    # Accepts model and collection from instantiator.
    initialize: ({@query, @view, @noTitle, @fetchSummary}) ->
      super
      @state.set(open: Options.get 'Facets.Initally.Open') unless @state.has 'open'
      @listenTo @query, 'change:constraints', @reRender
      @listenTo @state, 'change:open', @honourOpenness

    events: ->
      'click dt': 'toggle'

    toggle: -> @state.toggle 'open'

    close: -> @state.set open: false

    open: -> @state.set open: true

    honourOpenness: ->
      isOpen = @state.get 'open'
      facet = @$ '.im-facet'
      evt = new Event @, @el
      @trigger 'toggle', evt
      return if evt.cancelled
      if isOpen
        facet.slideDown()
        @trigger 'opened', @
      else
        facet.slideUp()
        @trigger 'closed', @
      @trigger 'toggled', @

    postRender: ->
      @renderChild 'title', (new FacetTitle {@model, @state}) unless @noTitle
      @honourOpenness()

