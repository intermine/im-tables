Icons = require '../../icons'
Attribute = require './attribute'
{ignore} = require '../../utils/events'

module.exports = class Reference extends Attribute

  initialize: ({@openNodes, @createSubFinder}) ->
    super
    @state.set collapsed: true
    @listenTo @openNodes, 'add remove', @setCollapsed
    @listenTo @state, 'change:collapsed', @onChangeCollapsed
    @setCollapsed()

  setCollapsed: ->
    # We need a guard because clean up seems to happen in the wrong order.
    @state?.set collapsed: not @openNodes.contains @path

  handleClick: (e) ->
    ignore e
    if @$(e.target).is('i') or (not @model.get('canSelectReferences'))
      @openNodes.togglePresence @path
    else
      super(e)

  getData: ->
    d = super
    d.icon = Icons.icon if @state.get('collapsed') then 'ClosedReference' else 'OpenReference'
    return d

  postRender: ->
    @onChangeCollapsed()

  onChangeCollapsed: ->
    if @state.get('collapsed')
      @removeChild 'subfinder'
    else
      trail = @trail.concat [@path]
      subfinder = @createSubFinder {trail}
      @renderChild 'subfinder', subfinder
