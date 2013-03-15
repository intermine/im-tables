define 'models/uniq-items', ->

  # Model for representing something with one major field
  class Item extends Backbone.Model

      initialize: (item) ->
          @set "item", item

  # Class for representing a collection of items, which must be unique.
  class UniqItems extends Backbone.Collection
      model: Item

      # Add items if they are non null, not empty strings,
      # and not already in the collection.
      add: (items, opts) ->
          items = if _(items).isArray() then items else [items]
          for item in items when item? and "" isnt item
              super(new Item(item, opts)) unless (@any (i) -> i.get("item") is item)
              
      remove: (item, opts) ->
          delenda = @filter (i) -> i.get("item") is item
          super(delenda, opts)
    
  UniqItems

