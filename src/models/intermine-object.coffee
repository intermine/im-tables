Backbone = require 'backbone'

module.exports = class IMObject extends Backbone.Model

  initialize: (obj, query, field, base, history) ->
    obj[field] = obj.value
    obj['obj:type'] = obj.class
    obj['service:base'] = base
    obj['service:url'] = obj.url
    obj['is:selected'] = false
    obj['is:selectable'] = true
    obj['is:selecting'] = false
    @set(obj)
    model = query.model
    query.on "selection:cleared", => @set 'is:selectable': true
    query.on "common:type:selected", (type) =>
      ok = not type or model.findSharedAncestor type, @get 'obj:type'
      @set 'is:selectable': !! ok
    @on "change:is:selected", (self, selected) =>
      query.trigger "imo:selected", @get("obj:type"), @get("id"), selected
    @on 'click', => query.trigger 'imo:click', @get('obj:type'), @get('id'), @toJSON()

  selectionState: ->
    selected: @get 'is:selected'
    selecting: @get 'is:selecting'
    selectable: @get 'is:selectable'

  merge: (obj, field) -> @set field, obj.value

