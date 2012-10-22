scope "intermine.model", (exporting) ->
    
    exporting class IMObject extends Backbone.Model

        initialize: (query, obj, field, base) ->
            obj._type = obj.class
            obj[field] = obj.value
            obj.base = base
            obj.selected = false
            obj.selectable = true
            @attributes = obj
            m = query.service.model
            pathInfo = m.getPathInfo(obj._type)
            query.on "selection:cleared", => @set selectable: true
            query.on "common:type:selected", (type) =>
                typesAreCompatible = type and (pathInfo.isa(type) or (m.getPathInfo(type).isa(@get("_type"))))
                @set selectable: (typesAreCompatible or !type)
            @on "change:selected", ->
                query.trigger "imo:selected", @get("_type"), @get("id"), @get("selected")

        merge: (obj, field) -> @set field, obj.value

    exporting class NullObject extends IMObject
        
        initialize: (query, field, type) ->
            @attributes = {}
            @set field, null
            @set 'id', null
            @set 'type', type
            @set 'selected', false
            @set 'selectable', false

        merge: () ->
        
    exporting class FPObject extends NullObject
        initialize: (query, obj, field) ->
            obj._type = obj.class
            obj[field] = obj.value
            obj.selected = false
            obj.selectable = false
            obj.base = ''
            @attributes = obj



