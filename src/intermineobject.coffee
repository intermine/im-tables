scope "intermine.model", (exporting) ->
    
    exporting class IMObject extends Backbone.Model

        initialize: (query, obj, field, base) ->
            obj.type = obj.class
            obj[field] = obj.value
            obj.base = base
            obj.selected = false
            obj.selectable = true
            @attributes = obj
            m = query.service.model
            pathInfo = m.getPathInfo(obj.type)
            query.on "selection:cleared", => @set selectable: true
            query.on "common:type:selected", (type) =>
                typesAreCompatible = type and (pathInfo.isa(type) or (m.getPathInfo(type).isa(@get("type"))))
                console.log obj.type, typesAreCompatible
                @set selectable: (typesAreCompatible or !type)
            @on "change:selected", ->
                query.trigger "imo:selected", @get("type"), @get("id"), @get("selected")

        merge: (obj, field) -> @set field, obj.value

