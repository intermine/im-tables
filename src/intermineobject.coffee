namespace "intermine.model", (public) ->
    
    public class IMObject extends Backbone.Model

        initialize: (query, obj, field, base) ->
            obj.type = obj.class
            obj[field] = obj.value
            obj.base = base
            obj.selected = false
            obj.selectable = true
            @attributes = obj
            query.on "imo:selected", (type) =>
                commonType = query.service.model.findCommonTypeOf(type, @get "type")
                @set selectable: commonType? and @get "selectable"
            @on "change:selected", ->
                query.trigger "imo:selected", @get("type"), @get("id"), @get("selected")

        merge: (obj, field) -> @set field, obj.value

