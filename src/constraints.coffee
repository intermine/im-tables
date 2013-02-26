scope "intermine.conbuilder.messages", {
    ValuePlaceholder: 'David*',
    ExtraPlaceholder: 'Wernham-Hogg',
    ExtraLabel: 'within',
    IsA: 'is a',
    CantEditConstraint: 'No value selected. Please enter a value.'
}

do ->

    PATH_SEGMENT_DIVIDER = "&rarr;"

    class ActiveConstraint extends Backbone.View
        tagName: "form"
        className: "form-inline im-constraint row-fluid"
        
        initialize: (@query, @orig) ->
            @typeaheads = []
            @path = @query.getPathInfo @orig.path
            @type = @path.getEndClass()
            @con = new Backbone.Model(_.extend({}, @orig))
            if @path.isClass()
                @ops = intermine.Query.REFERENCE_OPS
            else if @path.getType() in intermine.Model.BOOLEAN_TYPES
                @ops = ["=", "!="].concat(intermine.Query.NULL_OPS)
            else if @con.has('values')
                @ops = intermine.Query.ATTRIBUTE_OPS
            else
                @ops = intermine.Query.ATTRIBUTE_VALUE_OPS.concat(intermine.Query.NULL_OPS)

        events:
            'change .im-ops': 'drawValueOptions'
            'click .icon-edit': 'toggleEditForm'
            'click .btn-cancel': 'hideEditForm'
            'click .btn-primary': 'editConstraint'
            'click .icon-remove-sign': 'removeConstraint'
            'submit': (e) -> e.preventDefault(); e.stopPropagation()

        toggleEditForm: ->
            @$('.im-con-overview').siblings().slideToggle 200
            @$('.im-value-options').show()

        hideEditForm: (e) ->
            e?.preventDefault()
            e?.stopPropagation()
            @$('.im-con-overview').siblings().slideUp 200
            while (ta = @typeaheads.shift())
                ta.remove()

        valid: () ->
            unless @con.has('op')
                return false
            op = @con.get('op')
            if op in intermine.Query.ATTRIBUTE_VALUE_OPS.concat(intermine.Query.REFERENCE_OPS)
                return @con.has('value')
            if op in intermine.Query.MULTIVALUE_OPS
                return @con.has('values')
            return true

        editConstraint: (e) ->
            e.stopPropagation()
            e.preventDefault()

            if not @valid()
                @$el.addClass 'error'
                return false

            @removeConstraint(e, silently = true)
            if @con.get('op') in intermine.Query.MULTIVALUE_OPS.concat(intermine.Query.NULL_OPS)
                @con.unset('value')
            if @con.get('op') in intermine.Query.ATTRIBUTE_VALUE_OPS.concat(intermine.Query.NULL_OPS)
                @con.unset('values')

            if (@con.get('op') in intermine.Query.MULTIVALUE_OPS) and @con.get('values').length is 0
                # we remove one, so trigger that change.
                @query.trigger "change:constraints"
            else
                @query.addConstraint @con.toJSON()
            while (ta = @typeaheads.shift())
                ta.remove()

        removeConstraint: (e, silently = false) ->
            @query.removeConstraint @orig, silently

        addIcons: ($label) ->
            $label.append """<a href="#"><i class="icon-remove-sign"></i></a>"""
            if @con.locked
                $label.append """<a href="#"><i class="icon-lock" title="this constraint is not editable"></i></a>"""
            else
                $label.append """<a href="#"><i class="icon-edit"></i></a>"""

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
                <div class="btn-group im-con-buttons">
                </div>
            """
            for {text: t, class: c} in @buttons then do ->
                btns.append """<button class="#{c}">#{t}</button>"""

            @$el.append btns

        getTitleOp: () -> @con.get('op') or intermine.conbuilder.messages.IsA
        getTitleVal: () ->
            if @con.get('values')
                @con.get('values').length + " values"
            else
                @con.get('value') or @con.get('type')

        toLabel: (content, type) -> $ """<span class="label label-#{type}">#{content}</span>"""

        fillConSummaryLabel: () ->
            @label.empty()
            @addIcons @label
            ul = $('<ul class="breadcrumb">').appendTo @label

            if @con.has 'title'
                ul.append @toLabel @con.get('title'), 'path'
            else
                sp = @toLabel @path, 'path'
                do (sp) => @path.getDisplayName (name) -> sp.text name
                ul.append(sp)
            if (op = @getTitleOp())
                ul.append @toLabel op, 'op'
            unless @con.get('op') in intermine.Query.NULL_OPS
                if (val = @getTitleVal())
                    ul.append @toLabel val, 'value'
                if @con.has 'extraValue'
                    ul.append intermine.conbuilder.messages.ExtraLabel
                    ul.append @toLabel @con.get('extraValue'), 'extra'

        render: ->
            @label = $ """
                <label class="im-con-overview">
                </label>
            """
            @fillConSummaryLabel()
            @$el.append @label
            fs = $("""<fieldset class="im-constraint-options"></fieldset>""").appendTo @el
            @drawOperatorSelector(fs)
            @drawValueOptions()
            @$el.append """
                <div class="alert alert-error span10 hidden">
                    <i class="icon-warning-sign"></i>
                    #{ intermine.conbuilder.messages.CantEditConstraint }
                </div>
            """
            @addButtons()
            this

        drawOperatorSelector: (fs) ->
            current = @con.get 'op'
            $select = $ """<select class="span4 im-ops"><option>#{ current }</option></select>"""
            $select.appendTo fs
            _(@ops).chain().without(current).each (op) -> $select.append "<option>#{ op }</select>"
            $select.change (e) => @con.set op: $select.val()

        btnGroup: """<div class="im-value-options btn-group" data-toggle="buttons-radio"></div>"""

        drawBooleanOpts: (fs) ->
            current = @con.get 'value'
            con = @con
            grp = $(@btnGroup).appendTo fs
            for val in ['true', 'false'] then do (val) =>
                button = $ """
                        <button class="btn #{ if (current is val) then 'active' else ''}">
                            #{ val }
                        </button>
                    """
                button.appendTo grp
                button.click (e) => # For some reason the buttons plugin isn't working, grrr
                    wasActive = button.is '.active'
                    grp.find('button').removeClass 'active'
                    unless wasActive
                        button.addClass 'active'
                        @con.set value: val
                    else
                        @con.unset 'value'

        valueSelect: """<select class="span7 im-value-options im-con-value"></select>"""
        listOptionTempl: _.template """
            <option value="<%- name %>">
                <%- name %> (<%- size %> <%- type %>s)
            </option>
        """
        multiValueTable: '<table class="table table-condensed im-value-options"></table>'
        multiValueOptTempl: _.template """
            <tr>
                <td><input type=checkbox checked data-value="<%- value %>"></td>
                <td><%- value %></td>
            </tr>
        """
        clearer: '<div class="im-value-options" style="clear:both;">'

        drawMultiValueOps: (fs) ->
            con = @con
            con.set(values: []) unless con.has('values')
            values = con.get('values')
            $multiValues = $(@multiValueTable).appendTo fs
            _(values).each (v) => $multiValues.append @multiValueOptTempl value: v
            $multiValues.find('input').change (e) ->
                changed = $ @
                value = changed.data 'value'
                if changed.is ':checked'
                    values.push(value) unless (_.include(values, value))
                else
                    values = _.without(values, value)
                    con.set values: values

        drawListOptions: (fs) ->
            $lists = $(@valueSelect).appendTo fs
            @query.service.fetchLists (ls) =>
                selectables = _(ls).filter (l) => l.size and @path.isa l.type
                for sl in selectables
                    $lists.append @listOptionTempl sl
                $lists.val @con.get('value') if @con.has('value')
                if selectables.length is 0
                    $lists.attr disabled: true
                    $lists.append 'No lists of this type available'
                else
                    @con.set value: $lists.val()
            $lists.change (e) => @con.set value: $lists.val()

        drawLoopOpts: (fs) ->
            $loops = $(@valueSelect).appendTo(fs)
            loopCandidates = @query.getQueryNodes().filter (lc) =>
                lc.isa(@type) or @path.isa(lc.getEndClass())
            for lc in loopCandidates
                opt = $ """<option value="#{ lc.toString() }">"""
                opt.appendTo $loops
                do (opt, lc) -> lc.getDisplayName (name) -> opt.text name

        handleSummary: (input, items, total) ->
            if total <= 500 # Only offer typeahead if there are fewer than 500 items.
                input.typeahead source: _.pluck(items, 'item')
                # horrible hack to get correct typeahead placement
                @typeaheads.push input.data('typeahead').$menu
                input.keyup () ->
                    input.data('typeahead').$menu.css
                        top: input.offset().top + input.height()
                        left: input.offset().left
                @query.on 'cancel:add-constraint', () ->
                    input.data('typeahead')?.$menu.remove()
            input.attr placeholder: items[0].item # Suggest the most common item

        handleNumericSummary: (input, summary) ->
            isInt = @path.getType() in ['int', 'Integer']
            step = if isInt then 1 else 0.1
            caster = if isInt then parseInt else parseFloat
            fs = input.closest('fieldset')
            fs.append @clearer
            $slider = $ '<div class="im-value-options">'
            $slider.appendTo(fs).slider
                min: summary.min
                max: summary.max
                value: (@con.get('value') or summary.average)
                step: step
                slide: (e, ui) -> input.val(ui.value).change()
            input.attr placeholder: caster(summary.average)
            fs.append @clearer
            input.change (e) -> $slider.slider('value', input.val())
        
        drawAttributeOpts: (fs) ->
            input = $ """
                <input class="span7 im-constraint-value im-value-options im-con-value" type="text"
                    placeholder="#{ intermine.conbuilder.messages.ValuePlaceholder }"
                    value="#{ @con.get('value') or @con.get('type') or '' }"
                >
            """
            fs.append input
            input.keyup () => @con.set value: input.val()
            input.change () => @con.set value: input.val()
            withOutThisConstraint = @query.clone()
            withOutThisConstraint.constraints = withOutThisConstraint.constraints.filter((c) => not ((c.path is @path.toString()) and (c.value is @con.get('value'))))
            withOutThisConstraint.filterSummary @path.toString(), "", 500, (items, total) =>
                if items?.length > 0
                    if items[0].item? # string-ish values.
                        @handleSummary(input, items, total)
                    else if items[0].max? # numeric values
                        @handleNumericSummary(input, items[0])

        drawExtraOpts: (fs) ->
            fs.append """
                <label class="im-value-options">
                    #{ intermine.conbuilder.messages.ExtraLabel }
                    <input type="text" class="im-extra-value"
                        placeholder="#{ intermine.conbuilder.messages.ExtraPlaceholder }"
                        value="#{ @con.get('extraValue') or '' }"
                    >
                </label>
            """
            input = fs.find('input.im-extra-value').change (e) => @con.set extraValue: input.val()

        drawValueOptions: ->
            @$('.im-value-options').remove()
            fs = @$ '.im-constraint-options'
            currentOp = @con.get 'op'
            if (@path.getType() in intermine.Model.BOOLEAN_TYPES) and not (currentOp in intermine.Query.NULL_OPS)
                @drawBooleanOpts(fs)
            else if currentOp in intermine.Query.MULTIVALUE_OPS
                @drawMultiValueOps(fs)
            else if currentOp in intermine.Query.LIST_OPS
                @drawListOptions(fs)
            else if @path.isReference() and (currentOp in ['=', '!='])
                @drawLoopOpts(fs)
            else if not (currentOp in intermine.Query.NULL_OPS)
                @drawAttributeOpts(fs)

            if currentOp in intermine.Query.TERNARY_OPS
                @drawExtraOpts(fs)

    class NewConstraint extends ActiveConstraint

        initialize: (q, c) ->
            super q, c
            @$el.addClass "new"
            @buttons[0].text = "Apply"
            @con.set op: (if @type then 'LOOKUP' else '=')
            @con.on 'change', @fillConSummaryLabel, @

        addIcons: ->

        valueChanged: (value) -> @fillConSummaryLabel _.extend({}, @con, {value: value})

        opChanged: (op) -> @$('.label-op').text op

        removeConstraint: () -> # Nothing to do - just suppress this.

        hideEditForm: (e) ->
            super(e)
            @query.trigger "cancel:add-constraint"
            @remove()

    scope "intermine.query", {ActiveConstraint, NewConstraint}
