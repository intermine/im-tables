scope "intermine.query",  (exporting) ->

    PATH_SEGMENT_DIVIDER = "&rarr;"

    exporting class ActiveConstraint extends Backbone.View
        tagName: "form"
        className: "form-inline im-constraint row-fluid"
        
        initialize: (@query, @con) ->
            @pathInfo = @query.getPathInfo @con.path
            @type = @pathInfo.getEndClass()
            if @pathInfo.isClass()
                @ops = intermine.Query.REFERENCE_OPS
            else if @pathInfo.getType() in intermine.Model.BOOLEAN_TYPES
                @ops = ["=", "!="]
            else
                @ops = intermine.Query.ATTRIBUTE_OPS

        events:
            'change .im-ops': 'drawValueOptions'
            'click .icon-edit': 'toggleEditForm'
            'click .btn-cancel': 'hideEditForm'
            'click .btn-primary': 'editConstraint'
            'click .icon-remove-sign': 'removeConstraint'
            'submit': 'handleSubmit'

        handleSubmit: (e) ->
            e.preventDefault()
            e.stopPropagation()
            false

        toggleEditForm: ->
            @$('.im-con-overview').siblings().slideToggle 200
            @$('.im-value-options').show()

        hideEditForm: (e) ->
            e?.preventDefault()
            e?.stopPropagation()
            @$('.im-con-overview').siblings().slideUp 200
        editConstraint: ->
            @updateConstraint()
            @query.trigger "change:constraints"

        updateConstraint: ->
            op = @$('.im-ops').val()
            con = op: op
            if op in intermine.Query.MULTIVALUE_OPS
                con.values = @$('.im-constraint-options input[type="checkbox"]')
                               .filter(-> $(@).attr "checked")
                               .map(-> $(@).data 'value').get()
            else
                con.value = @$('.im-value-options').val()
            _.extend(@con, con)

        removeConstraint: ->
            @query.removeConstraint @con

        addIcons: ($label) ->
            $label.append """<i class="icon-remove-sign"></i>"""
            if @con.locked
                $label.append """<i class="icon-lock" title="this constraint is not editable"></i>"""
            else
                $label.append """<i class="icon-edit"></i>"""

        buttons: [
            {
                text: "Update",
                class: "btn btn-primary"
            },
            {
                text: "Cancel",
                class: "btn btn-cancel"
            }
        ]

        addButtons: ->
            btns = $ """
                <div class="btn-group">
                </div>
            """
            for {text: t, class: c} in @buttons then do ->
                btns.append """<button class="#{c}">#{t}</button>"""

            @$el.append btns

        getTitleParts: -> if @con.title then [@con.title] else @con.path.replace(/^[^\.]+\.?/, "").split(".")
        getTitleOp: -> @con.op or "is a"
        getTitleVal: -> if @con.values then @con.values.length + " values" else @con.value or @con.type

        render: ->
            parts = @getTitleParts()
            #end = parts.pop()
            #parts.push end + " #{@getTitleOp()} #{@getTitleVal()}"
            conDetails = []
            conDetails.push(op) if (op = @getTitleOp())
            conDetails.push(val) if (val = @getTitleVal())

            lis = ("""<li class="#{if i + 1 is parts.length then 'active' else ''}">#{p}</li>""" for p, i in parts)
            lisB = ("""<li>#{p}</li>""" for p in conDetails)
            
            $label = $ """
                <label class="im-con-overview">
                    <ul class="im-con-summary breadcrumb">
                        #{lis.join "<span class='divider'>#{ PATH_SEGMENT_DIVIDER }</span>"}
                        #{lisB.join '&nbsp'}
                    </ul>
                </label>
            """
            @$el.append $label
            @addIcons $label
            fs = $("""<fieldset class="im-constraint-options"></fieldset>""").appendTo @el

            $select = $ """<select class="span4 im-ops"><option>#{ @con.op }</option></select>"""
            $select.appendTo fs
            _(@ops).chain().without(@con.op).each (op) -> $select.append """<option>#{ op }</select>"""
            @drawValueOptions()
            @addButtons()
            this

        drawValueOptions: ->
            @$('.im-value-options').remove()
            fs = @$ '.im-constraint-options'
            op = @$('.im-ops').val()
            if @pathInfo.getType() in intermine.Model.BOOLEAN_TYPES
                fs.append """
                    <div class="btn-group" data-toggle="buttons-radio">
                        <button class="btn #{if @con.value is 'true' then 'active' else ''}" data-value="true">
                            true
                        </button>
                        <button class="btn #{if @con.value is 'false' then 'active' else ''}" data-value="false">
                            false
                        </button>
                    </div>
                    <input class="im-value-options" type="hidden" value="#{@con.value}">
                """

            else if op in intermine.Query.MULTIVALUE_OPS
                values = @con.values or []
                $multiValues = $('<table class="table table-condensed im-value-options"></table>').appendTo fs
                _(values).each (v) -> $multiValues.append """
                        <tr>
                            <td><input type=checkbox checked data-value="#{ v }"></td>
                            <td>#{ v }</td>
                        </tr>
                    """
            else if op in intermine.Query.LIST_OPS
                $lists = $("""<select class="im-value-options"></select>""").appendTo fs
                @query.service.fetchLists (ls) =>
                    selectables = _(ls).filter (l) => l.size and l.type is @type.name
                    for sl in selectables
                        $lists.append """<option value="#{ sl.name }">#{ sl.name } (#{sl.size} #{sl.type}s)</option>"""
                    $lists.val @con.value if @con.value
            else
                fs.append """
                    <input class="span7 im-constraint-value im-value-options" type="text" 
                        value="#{ @con.value or @con.type }">
                """

            if op in intermine.Query.TERNARY_OPS
                fs.append """
                    <input type="text" class="im-extra-value im-value-options" placeholder="restricting to..."
                        value="#{ @con.extraValue }"
                    >
                """

    exporting class NewConstraint extends ActiveConstraint

        initialize: (@query, @con) ->
            super @query, @con
            @$el.addClass "new"
            @buttons[0].text = "Apply"
            if @type
                @con.op = "LOOKUP"
            else
                @con.op = "="

        addIcons: ->

        hideEditForm: ->
            @query.trigger "cancel:add-constraint"
            @remove()

        updateConstraint: ->
            super()
            @query.addConstraint @con


