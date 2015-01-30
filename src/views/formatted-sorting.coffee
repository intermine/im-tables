CoreView = require '../core-view'
Templates = require '../templates'
SortedPath = require './formatted/sorting-path'

sortQueryByPath = require '../utils/sort-query-by-path'

# A class that handles the machinery for letting users choose which column
# to sort by when a column represents multiple paths due to formatting.
module.exports = class FormattedSorting extends CoreView

  className: 'im-col-sort-menu no-margins'

  tagName: 'ul'

  initialize: ({@query}) ->
    super
    @setPathNames() # initialise the path display name dictionary

  modelEvents: ->
    'change:displayName': @initState
    'change:replaces': @setPathNames

  initState: ->
    @state.set group: @model.get('displayName')

  # in this class we make use of the state as a path display name lookup
  # dictionary which means we also need to make sure we have an entry of
  # each of them.
  setPathNames: -> for p in @getPaths() then do (p) =>
    key = p.toString()
    @state.set key, '' unless @state.has key
    p.getDisplayName().then (name) => @state.set key, name

  # :: [PathInfo]
  getPaths: ->
    replaces = @model.get('replaces')
    if replaces.length
      replaces.slice()
    else
      [@query.makePath @model.get('path')]

  preRender: (e) ->
    [path] = paths = @getPaths()   # find the paths, and extract the first one.
    if paths.length is 1           # Nothing for the user to choose from
      e.cancel()                   # cancels impending render.
      sortQueryByPath @query, path # sort on the first (and only) path

  # templateless render - it is all about the child views.
  postRender: -> for p, i in @getPaths()
    @renderChild i, (new SortedPath {@model, @state, @query, path: p})

