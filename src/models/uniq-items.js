let UniqItems;
const Backbone = require('backbone');
const _ = require('underscore');
const CoreModel = require('../core-model');
const Collection = require('../core/collection');

// OK, this is kind of daft. We could/should be using the
// standard Backbone.Collection id property.

// Model for representing something with one major field
//
// Other fields are possible, but this model is identified with
// and indexed by the 'item' field.
class Item extends CoreModel {

  initialize(item, props) {
    if (props != null) { this.set(props); } // MUST not contain an item prop.
    return this.set({item, id: String(item)}); // index by item.
  }
}

// Class for representing a collection of items, which must be unique.
// Each item is represented werapped up in its own {item: item}
// model, and no two models will exist in the collection where 
// item is item.
module.exports = (UniqItems = (function() {
  UniqItems = class UniqItems extends Collection {
    static initClass() {
  
      this.prototype.model = Item;
    }

    toJSON() { return (Array.from(this.models).map((m) => m.get('item'))); }

    togglePresence(item) {
      if (this.contains(item)) {
        return this.remove(item);
      } else {
        return this.add(item);
      }
    }

    get(key) {
      return super.get((key instanceof Backbone.Model) ? key : String(key));
    }

    contains(item) {
      if (item instanceof Item) {
        return super.contains(item);
      } else {
        return (this.findWhere({item}) != null);
      }
    }

    // Add items if they are non null, not empty strings,
    // and not already in the collection.
    // The API is slightly different from Collection::add in that the
    // second argument defines the secondary properties of the model.
    add(items, props) {
      items = _(items).isArray() ? items : [items];
      return (() => {
        const result = [];
        for (let item of Array.from(items)) {
          if ((item != null) && ("" !== item)) {
            if (!this.contains(item)) { result.push(super.add(new Item(item, props))); } else {
              result.push(undefined);
            }
          }
        }
        return result;
      })();
    }
          
    remove(items, opts) {
      items = _(items).isArray() ? items : [items];
      return Array.from(items).map((item) =>
        item instanceof Item ?
          super.remove(item, opts)
        :
          super.remove(this.findWhere({item}), opts));
    }
  };
  UniqItems.initClass();
  return UniqItems;
})());
