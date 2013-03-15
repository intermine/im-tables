do ->
    
    # TODO. Separate the data fields from things like selectable.
    # This could be done with name-spacing such as a dot, colon or dash
    # which are illegal field name characters.
    class IMObject extends Backbone.Model

        initialize: (query, obj, field, base) ->
            obj._type = obj.class
            obj[field] = obj.value
            obj.base = base
            obj.selected = false
            obj.selectable = true
            obj.selecting = false
            @attributes = obj
            pathInfo = query.model.getPathInfo(obj._type)
            query.on "selection:cleared", => @set selectable: true
            query.on "common:type:selected", (type) =>
                typesAreCompatible = type and (pathInfo.isa(type) or (query.model.getPathInfo(type).isa(@get("_type"))))
                @set selectable: (typesAreCompatible or !type)
            @on "change:selected", ->
                query.trigger "imo:selected", @get("_type"), @get("id"), @get("selected")

        merge: (obj, field) -> @set field, obj.value

    class NullObject extends IMObject
        
        initialize: (query, field, type) ->
            @attributes = {}
            @set field, null
            @set 'id', null
            @set 'type', type
            @set 'selected', false
            @set 'selectable', false

        merge: () ->
        
    class FPObject extends NullObject
        initialize: (query, obj, field) ->
            obj._type = obj.class
            obj[field] = obj.value
            obj.selected = false
            obj.selectable = false
            obj.base = ''
            @attributes = obj

    scope "intermine.model", {IMObject, NullObject, FPObject}

