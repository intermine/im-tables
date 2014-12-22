Icons = require '../../icons'
Attribute = require './attribute'

module.exports = class Reference extends Attribute

  initialize: ({@openNodes, @createSubFinder}) ->
    super
    @state.set collapsed: true
    @listenTo @openNodes, 'add remove', @setCollapsed
    @listenTo @state, 'change:collapsed', @render
    @setCollapsed()

  setCollapsed: ->
    # We need a guard because clean up seems to happen in the wrong order.
    @state?.set collapsed: not @openNodes.contains @path

  handleClick: (e) ->
    e?.preventDefault()
    e?.stopPropagation()
    if @$(e.target).is('i') or (not @model.get('canSelectReferences'))
      @openNodes.togglePresence @path
    else
      super(e)

  getData: ->
    d = super
    d.icon = Icons.icon if @state.get('collapsed') then 'ClosedReference' else 'OpenReference'
    return d

  render: ->
    super
    unless @state.get('collapsed')
      trail = @trail.concat [@path]
      subfinder = @createSubFinder {trail}
      @renderChild 'subfinder', subfinder
