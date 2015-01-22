_ = require 'underscore'

CoreView = require '../../core-view'
Collection = require '../../core/collection'
Templates = require '../../templates'

PathModel = require '../../models/path'

decr = (i) -> i - 1
incr = (i) -> i + 1

# (*) Note that when we use the buttons to re-arrange, we do the swapping in
# the event handlers. This is ugly, since we are updating the model _and_ the
# DOM in the same method, rather than having the DOM reflect the model.
# However, the reason for this is as follows: there are two ways to rearrange
# the view - dragging or button clicks. Dragging does not need a re-render,
# just a model update, which is performed in the parent component; Button
# clicks don't need a re-render as such, just a re-arrangement, but
# re-arranging on change:index would cause re-renders when the model is updated
# after drag, causing flicker. Also, we don't really _need_ to re-render the
# whole parent, just swap two neighbouring elements. Since this is easy to do,
# it makes sense to do it here.
#
# As for the moveUp/moveDown methods - these are only available when the view
# is not first/last, this they are null safe with regards to prev/next models.
module.exports = class SelectedColumn extends CoreView

  Model: PathModel

  tagName: 'li'

  className: 'list-group-item im-selected-column'

  modelEvents: ->
    'change:displayName': 'resetParts'

  template: Templates.template 'column-manager-selected-column'

  getData: ->
    isLast = (@model is @model.collection.last())
    _.extend super, isLast: isLast, parts: (@parts.map (p) -> p.get 'part')

  initialize: ->
    super
    @parts = new Collection
    @listenTo @parts, 'add remove reset', @reRender
    @resetParts()
    @listenTo @model.collection, 'sort', @reRender

  resetParts: -> if @model.get 'displayName'
    @parts.reset({part, id} for part, id in @model.get('displayName').split(' > '))

  postRender: ->
    # Activate tooltips.
    @$('[title]').tooltip container: @$el

  events: ->
    'click .im-remove-view': 'removeView'
    'click .im-move-up': 'moveUp'
    'click .im-move-down': 'moveDown'
    'binned': 'removeView'

  # Move this view element to the right.
  moveDown: ->
    next = @model.collection.at incr @model.get 'index'
    next.swap 'index', decr
    @model.swap 'index', incr
    @$el.insertAfter @$el.next() # this is ugly, but see *

  # Move this view element to the left.
  moveUp: ->
    prev = @model.collection.at decr @model.get 'index'
    prev.swap 'index', incr
    @model.swap 'index', decr
    @$el.insertBefore @$el.prev() # this is ugly, but see *

  removeView: ->
    @model.collection.remove @model
    @model.destroy()
