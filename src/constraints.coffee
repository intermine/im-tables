scope "intermine.conbuilder.messages", {
    ValuePlaceholder: 'David*',
    ExtraPlaceholder: 'Wernham-Hogg',
    ExtraLabel: 'within',
    IsA: 'is a'
}

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
                @ops = ["=", "!="].concat(intermine.Query.NULL_OPS)
            else
                @ops = intermine.Query.ATTRIBUTE_OPS

        events:
            'change .im-ops': 'drawValueOptions'
            'click .icon-edit': 'toggleEditForm'
            'click .btn-cancel': 'hideEditForm'
            'click .btn-primary': 'editConstraint'
            'click .icon-remove-sign': 'removeConstraint'
            'submit': (e) -> e.preventDefault()

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

        valueChanged: (value) ->

        updateConstraint: ->
            op = @$('.im-ops').val()
            con = op: op
            if op in intermine.Query.MULTIVALUE_OPS
                con.values = @$('.im-constraint-options input[type="checkbox"]')
                               .filter(-> $(@).attr "checked")
                               .map(-> $(@).data 'value').get()
            else
                con.value = @$('.im-con-value').val()
            if op in intermine.Query.TERNARY_OPS
                con.extraValue = @$('.im-extra-value').val()
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

        getTitleOp: (con) -> con.op or intermine.conbuilder.messages.IsA
        getTitleVal: (con) -> if con.values then con.values.length + " values" else con.value or con.type

        toLabel: (content, type) -> $ """<span class="label label-#{type}">#{content}</span>"""

        fillConSummaryLabel: (con) ->
            @label.empty()
            @addIcons @label
            ul = $('<ul class="breadcrumb">').appendTo @label

            if con.title?
                ul.append @toLabel con.title, 'path'
            else
                sp = @toLabel con.path, 'path'
                do (sp) => @query.getPathInfo(con.path).getDisplayName (name) -> sp.text name
                ul.append(sp)
            if (op = @getTitleOp(con))
                ul.append @toLabel op, 'op'
            if (val = @getTitleVal(con))
                ul.append @toLabel val, 'value'

        render: ->
            @label = $ """
                <label class="im-con-overview">
                </label>
            """
            @fillConSummaryLabel @con
            @$el.append @label
            fs = $("""<fieldset class="im-constraint-options"></fieldset>""").appendTo @el

            $select = $ """<select class="span4 im-ops"><option>#{ @con.op }</option></select>"""
            $select.appendTo fs
            _(@ops).chain().without(@con.op).each (op) -> $select.append """<option>#{ op }</select>"""
            @drawValueOptions()
            @addButtons()
            this

        opChanged: (op) ->

        drawValueOptions: ->
            @$('.im-value-options').remove()
            fs = @$ '.im-constraint-options'
            op = @$('.im-ops').val()
            @opChanged op
            if (@pathInfo.getType() in intermine.Model.BOOLEAN_TYPES) and not (op in intermine.Query.NULL_OPS)
                fs.append """
                    <div class="im-value-options btn-group" data-toggle="buttons-radio">
                        <button class="btn #{if @con.value is 'true' then 'active' else ''}" data-value="true">
                            true
                        </button>
                        <button class="btn #{if @con.value is 'false' then 'active' else ''}" data-value="false">
                            false
                        </button>
                    </div>
                    <input class="im-value-options im-con-value" type="hidden" value="#{@con.value}">
                """
                input = fs.find('input').change( () => @valueChanged(input.val()) )

                fs.find('button').click (e) ->
                    b = $(@)
                    wasActive = b.is '.active'
                    fs.find('button').removeClass 'active'
                    unless wasActive
                        b.addClass('active')
                        input.val(b.data('value')).change()
                    else
                        input.val('').change()

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
                $lists = $("""<select class="span8 im-value-options im-con-value"></select>""").appendTo fs
                @query.service.fetchLists (ls) =>
                    selectables = _(ls).filter (l) => l.size and @pathInfo.isa l.type
                    for sl in selectables
                        $lists.append """<option value="#{ sl.name }">#{ sl.name } (#{sl.size} #{sl.type}s)</option>"""
                    $lists.val @con.value if @con.value
                    if ls.length is 0
                        $lists.attr disabled: true
                        $lists.append 'No lists of this type available'
            else if @pathInfo.isReference() and (op in ['=', '!=']) # Loop constraint
                loopCandidates = @query.getQueryNodes().filter (lc) =>
                    lc.isa(@type) or @pathInfo.isa(lc.getEndClass())
                $loops = $ """<select class="span8 im-value-options im-con-value">"""
                $loops.appendTo(fs)
                for lc in loopCandidates
                    opt = $ """<option value="#{ lc.toString() }">"""
                    opt.appendTo $loops
                    do (opt, lc) -> lc.getDisplayName (name) -> opt.text name
            else if not (op in intermine.Query.NULL_OPS)
                input = $ """
                    <input class="span8 im-constraint-value im-value-options im-con-value" type="text"
                        placeholder="#{ intermine.conbuilder.messages.ValuePlaceholder }"
                        value="#{ @con.value or @con.type or '' }"
                    >
                """
                fs.append input
                input.keyup () => @valueChanged(input.val())
                input.change () => @valueChanged(input.val())
                do (input) =>
                    @query.filterSummary @con.path, "", 100, (items) ->
                        if (items?.length > 0) and (items[0].item?)
                            input.typeahead source: _.pluck(items, 'item')
                    @query.on 'cancel:add-constraint change:constraints', () ->
                        input.data('typeahead').$menu.remove()

            if op in intermine.Query.TERNARY_OPS
                fs.append """
                    <label class="im-value-options">
                        #{ intermine.conbuilder.messages.ExtraLabel }
                        <input type="text" class="im-extra-value"
                            placeholder="#{ intermine.conbuilder.messages.ExtraPlaceholder }"
                            value="#{ @con.extraValue || '' }"
                        >
                    </label>
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

        valueChanged: (value) -> @fillConSummaryLabel _.extend({}, @con, {value: value})

        opChanged: (op) -> @$('.label-op').text op

        hideEditForm: (e) ->
            super(e)
            @query.trigger "cancel:add-constraint"
            @remove()

        updateConstraint: ->
            super()
            @query.addConstraint @con


