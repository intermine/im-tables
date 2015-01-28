_ = require 'underscore'
Collection = require '../core/collection'
StepModel = require './step'

module.exports = class History extends Collection

  model: StepModel

  currentQuery: null

  initialize: ->
    super
    @listenTo @, 'remove', @unwatch
    @listenTo @, 'add', @watch

  # Monotonically increasing revision counter.
  currentStep: 0

  # Sort by revision.
  # (Not really needed, but good to be explicit).
  comparator: 'revision'

  # The current query is the query of the last (most
  # recent) state.
  getCurrentQuery: -> @currentQuery

  setCurrentQuery: (m) ->
    @currentQuery = m.get('query').clone()

  # Stop listening to changes to the current query,
  # or the given query.
  unwatch: (model) ->
    q = (model?.get('query') ? @getCurrentQuery())
    return unless q? # Nothing to stop listening to!
    @stopListening q

  watch: (m) ->
    @setCurrentQuery m
    q = @getCurrentQuery()
    return unless q?
    @listenTo q, "change:constraints", @onChangeConstraints
    @listenTo q, "change:views", @onChangeViews
    @listenTo q, "change:joins", @onChangeJoins
    @listenTo q, "change:sortorder", @onChangeSortOrder
    @listenTo q, "undo", @popState

  # TODO - get rid of labels - they are pointless. Use the query prop instead

  onChangeConstraints: ->
    @onChange 'constraints', 'filter', JSON.stringify

  onChangeViews: ->
    @onChange 'views', 'column'

  onChangeJoins: ->
    @onChange 'joins', 'join', (style, path) -> "#{ path }:#{ style }"

  onChangeSortOrder: ->
    @onChange 'sortOrder', 'sort order element', JSON.stringify

  # Inform clients that the current query is different
  triggerChangedCurrent: ->
    @trigger 'changed:current', @last()

  # Handle a change event, analysing what has changed
  # and adding a step that records that change.
  onChange: ( prop, label, f = (x) -> x ) ->
    query = @currentQuery
    prev = @last().get 'query'
    xs = _.map prev[prop], f
    ys = _.map query[prop], f
    was = xs.length
    now = ys.length
    n = Math.abs was - now

    verb = switch
      when was < now then 'Added'
      when was > now then 'Removed'
      when now is _.union(xs, ys).length then 'Rearranged'
      else 'Changed'

    @addStep verb, n, label, query

  # Set the root query of this history.
  setInitialState: (q) ->
    @reset() if @size()
    @addStep null, null, 'Initial', q

  # Add a new state to the history, setting it as the new
  # current query.
  addStep: (verb, number, label, query) ->
    was = @currentQuery
    now = query.clone()
    @unwatch() # unbind listeners for the current query.
    @add
      query: now
      revision: @currentStep++
      title:
        verb: verb
        number: number
        label: label
    was?.trigger 'replaced:by', now
    @triggerChangedCurrent()

  # Revert to the state before the most recent one.
  popState: -> @revertToIndex -2

  revertToIndex: (index) ->
    index = (@length + index) if index < 0
    now = @at index
    @revertTo now

  revertTo: (now) ->
    throw new Error('State not in history') unless @contains now
    was = @getCurrentQuery()
    revision = now.get 'revision'
    # Remove everything after the target
    while @last().get('revision') > revision
      @pop()
    @watch now # Nothing added, but the current query has changed.
    was?.trigger 'replaced:by', now.get('query')
    @triggerChangedCurrent()

