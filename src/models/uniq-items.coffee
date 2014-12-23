Backbone = require 'backbone'
_ = require 'underscore'
CoreModel = require '../core-model'

# Model for representing something with one major field
#
# Other fields are possible, but this model is identified with
# and indexed by the 'item' field.
class Item extends CoreModel

  initialize: (item) -> @set item: item

# Class for representing a collection of items, which must be unique.
# Each item is represented werapped up in its own {item: item}
# model, and no two models will exist in the collection where 
# item is item.
module.exports = class UniqItems extends Backbone.Collection

  model: Item

  toJSON: -> (m.get('item') for m in @models)

  togglePresence: (item) ->
    if @contains item
      @remove item
    else
      @add item

  contains: (item) ->
    if item instanceof Item
      super item
    else
      @findWhere({item})?

  # Add items if they are non null, not empty strings,
  # and not already in the collection.
  add: (items, opts) ->
    items = if _(items).isArray() then items else [items]
    for item in items when item? and "" isnt item
      super(new Item item, opts) unless @contains item
          
  remove: (items, opts) ->
    items = if _(items).isArray() then items else [items]
    for item in items
      if item instanceof Item
        super item, opts
      else
        super @findWhere({item}), opts
