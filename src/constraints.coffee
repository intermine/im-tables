scope "intermine.conbuilder.messages", {
    ValuePlaceholder: 'David*',
    ExtraPlaceholder: 'Wernham-Hogg',
    ExtraLabel: 'within',
    IsA: 'is a',
    NoValue: 'No value selected. Please enter a value.',
    Duplicate: 'This constraint is already on the query',
    TooManySuggestions: 'We cannot show you all the possible values'
}

do ->

    PATH_SEGMENT_DIVIDER = "&rarr;"

    MATCHER = (tooMany) -> (item) ->
      if (item is tooMany) or (not @query) or /^\s+$/.test(@query)
        true
      else
        parts = @query.toLowerCase().split(' ') ? []
        _.all parts, (p) ->  item.toLowerCase().indexOf(p) >= 0

    HIGHLIGHTER = (tooMany) -> (item) ->
      if item is tooMany
        tooMany
      else
        @constructor::highlighter.call(@, item)

    UPDATER = (tooMany) -> (item) ->
      if item is tooMany
        null # Ceci ne c'est pas un item
      else
        item

    TOO_MANY_SUGGESTIONS = _.template """
      <span class="alert alert-info">
        <i class="icon-info-sign"></i>
        #{ intermine.conbuilder.messages.TooManySuggestions }
        There are <%= extra %> values we could not include.
      </span>
    """

    aeql = (xs, ys) -> (not xs and not ys) or (xs and ys and _.all xs, (x) -> x in ys)

    basicEql = (a, b) ->
      return a is b unless (a and b)
      keys = _.union.apply _, [a, b].map _.keys
      same = true
      for k in keys
        [va, vb] = (x[k] for x in [a, b])
        same and= (if _.isArray va then aeql va, vb else va is vb)
      return same


    class ActiveConstraint extends Backbone.View
        tagName: "form"
        className: "form-inline im-constraint row-fluid"
        
        BASIC_OPS = intermine.Query.ATTRIBUTE_VALUE_OPS.concat intermine.Query.NULL_OPS

        initialize: (@query, @orig) ->
            @typeaheads = []
            @path = @query.getPathInfo @orig.path
            @type = @path.getType()
            @cast = if @type in intermine.Model.NUMERIC_TYPES then ((x) -> 1 * x) else ((x) -> '' + x)
            @con = new Backbone.Model(_.extend({}, @orig))
            if @path.isReference() or @path.isRoot()
                @ops = intermine.Query.REFERENCE_OPS
            else if @path.getType() in intermine.Model.BOOLEAN_TYPES
                @ops = ["=", "!="].concat(intermine.Query.NULL_OPS)
            else if @con.has('values')
                @ops = intermine.Query.ATTRIBUTE_OPS
            else
                @ops = BASIC_OPS
            @con.on 'change', @fillConSummaryLabel, @

        events:
            'change .im-ops': 'drawValueOptions'
            'click .im-edit': 'toggleEditForm'
            'click .btn-cancel': 'hideEditForm'
            'click .btn-primary': 'editConstraint'
            'click .icon-remove-sign': 'removeConstraint'
            'click td.im-multi-value': 'toggleRowCheckbox'
            'submit': (e) -> e.preventDefault(); e.stopPropagation()

        toggleRowCheckbox: (e) ->
          $td = $ e.target
          input = $td.prev().find('input')[0]
          input.checked = not input.checked
          $(input).trigger 'change'

        toggleEditForm: ->
            @$('.im-constraint-options').show()
            @$('.im-con-buttons').show()
            @$('.im-value-options').show()
            @$el.siblings('.im-constraint').slideUp()
            @$el.closest('.well').addClass 'im-editing'

        hideEditForm: (e) ->
            e?.preventDefault()
            e?.stopPropagation()
            @$el.removeClass 'error'
            @$el.siblings('.im-constraint').slideDown()
            @$el.closest('.well').removeClass 'im-editing'
            @$('.im-con-overview').siblings('[class*="im-con"]').slideUp 200
            @$('.im-multi-value-table input').prop('checked', true)
            @con.set _.extend {}, @orig
            while (ta = @typeaheads.shift())
                ta.remove()

        IS_BLANK = /^\s*$/

        valid: () ->
            if @con.has('type')
              return true # Using a select list - cannot be wrong

            if not @con.get('op') or IS_BLANK.test @con.get('op') # No operator.
              return false

            op = @con.get('op')
            if @path.isReference() and op in ['=', '!=']
                ok = try
                  @query.getPathInfo(@con.get('value'))
                  true
                catch e
                  false
                return ok
            if op in intermine.Query.ATTRIBUTE_VALUE_OPS.concat(intermine.Query.REFERENCE_OPS)
                val = @con.get 'value'
                return val? and (not IS_BLANK.test val) and (not _.isNaN val)
            if op in intermine.Query.MULTIVALUE_OPS
                return @con.has('values') and @con.get('values').length > 0
            return true

        isDuplicate: -> _.any @query.constraints, _.partial basicEql, @con.toJSON()

        setError: (key) ->
          @$el.addClass 'error'
          @$('.im-conbuilder-error').text intermine.conbuilder.messages[key]
          false

        editConstraint: (e) ->
            e?.stopPropagation()
            e?.preventDefault()

            if not @valid()
              return @setError 'NoValue'

            if @isDuplicate()
              return @setError 'Duplicate'

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
            true

        removeConstraint: (e, silently = false) ->
            @query.removeConstraint @orig, silently

        addIcons: ($label) ->
            $label.append """<a href="#"><i class="icon-remove-sign"></i></a>"""
            if @con.locked
                $label.append """<a href="#"><i class="icon-lock" title="this constraint is not editable"></i></a>"""
            else
                $label.append """<a href="#"><i class="im-edit #{ intermine.icons.Edit }"></i></a>"""

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
            else if @con.has('value')
                @con.get('value')
            else
              @con.get('type')

        toLabel = (content, type) ->
          $ """<span class="label label-#{type}">#{content}</span>"""

        fillConSummaryLabel: () ->
          return unless @label?
          @label.empty()
          @addIcons @label
          ul = $('<ul class="breadcrumb">').appendTo @label

          if @con.has 'title'
              ul.append toLabel @con.get('title'), 'path'
          else
              sp = toLabel @path, 'path'
              do (sp) => @path.getDisplayName (name) -> sp.text name
              ul.append(sp)
          if (op = @getTitleOp())
              ul.append toLabel op, 'op'
          unless @con.get('op') in intermine.Query.NULL_OPS
              val = @getTitleVal()
              ul.append toLabel val, 'value' if val?
              if @con.has 'extraValue'
                  ul.append intermine.conbuilder.messages.ExtraLabel
                  ul.append toLabel @con.get('extraValue'), 'extra'

        CON_OPTS = """<fieldset class="im-constraint-options"></fieldset>"""

        render: ->
          @label = $ """
            <label class="im-con-overview">
            </label>
          """
          @fillConSummaryLabel()
          @$el.append @label
          fs = $(CON_OPTS).appendTo @el
          @drawOperatorSelector(fs) if @con.has('op')
          @drawValueOptions()
          @$el.append """
            <div class="alert alert-error im-hidden">
              <i class="icon-warning-sign"></i>
              <span class="im-conbuilder-error">
              </span>
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

        drawTypeOpts: (fs) ->
          label = """<label class="span4">IS A</label>"""
          select = $ """
            <select class="span7">
            </select>
          """
          fs.append label
          fs.append select
          type = @con.get('type')
          subclasses = @query.getSubclasses()
          schema = @query.model
          delete subclasses[@path]
          baseType = schema.getPathInfo(@path, subclasses).getType()
          types = [type].concat schema.getSubclassesOf baseType

          for t in types then do (t) ->
            option = $ '<option>'
            option.attr value: t
            select.append option
            schema.getPathInfo(t).getDisplayName().done (name) ->
              option.text name

          select.change => @con.set type: select.val()

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

        multiValueTable: """
          <div class="im-value-options im-multi-value-table">
            <table class="table table-condensed"></table>
          </div>
        """

        multiValueOptTempl: _.template """
            <tr>
                <td><input type=checkbox checked data-value="<%- value %>"></td>
                <td class="im-multi-value"><%- value %></td>
            </tr>
        """
        clearer: '<div class="im-value-options" style="clear:both;">'

        drawMultiValueOps: (fs) ->
            con = @con
            con.set(values: []) unless con.has('values')
            values = con.get('values')
            $multiValues = $(@multiValueTable).appendTo fs
            table = $multiValues.find('table')
            _(values).each (v) => table.append @multiValueOptTempl value: v
            $multiValues.find('input').change @changeMultiValues

        changeMultiValues: (e) =>
          changed = $(e.target)
          values = @con.get 'values'
          value = changed.data 'value'
          if changed.prop('checked')
              values = _.union values, [value]
          else
              values = _.without values, value
          @con.set {values}

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
                lc.isa(@type) or @path.isa(lc.getType())
            for lc in loopCandidates
                opt = $ """<option value="#{ lc.toString() }">"""
                opt.appendTo $loops
                do (opt, lc) -> lc.getDisplayName (name) -> opt.text name

        handleSummary: (input, items, total) ->
          suggestions = ('' + item for item in _.pluck items, 'item')
          {MaxSuggestions} = intermine.options
          if total > MaxSuggestions
            tooMany = TOO_MANY_SUGGESTIONS extra: total - MaxSuggestions
            suggestions.push tooMany

          input.typeahead
            source: suggestions
            items: 20
            minLength: 0
            updater: UPDATER(tooMany)
            highlighter: HIGHLIGHTER(tooMany)
            matcher: MATCHER(tooMany)
          @typeaheads.push input.data('typeahead').$menu
          @query.on 'cancel:add-constraint', () ->
              input.data('typeahead')?.$menu.remove()
          input.attr placeholder: items[0].item # Suggest the most common item

        handleNumericSummary: (input, {min, max, average}) ->
            isInt = @path.getType() in intermine.Model.INTEGRAL_TYPES
            step = if isInt then 1 else (max - min / 100)
            caster = if isInt then parseInt else parseFloat
            fs = input.closest('fieldset')
            fs.append @clearer
            $slider = $ '<div class="im-value-options">'
            $slider.appendTo(fs).slider
                min: min
                max: max
                value: (if @con.has('value') then @con.get('value') else caster average)
                step: step
                slide: (e, ui) -> input.val(ui.value).change()
            input.attr placeholder: caster average
            fs.append @clearer
            input.change (e) -> $slider.slider 'value', caster input.val()
        
        drawAttributeOpts: (fs) ->
            input = $ """
                <input class="span7 im-constraint-value im-value-options im-con-value" type="text"
                    placeholder="#{ intermine.conbuilder.messages.ValuePlaceholder }"
                    value="#{ @con.get('value') or '' }"
                >
            """
            fs.append input
            setValue = => @con.set value: @cast input.val()?.trim()
            input.keyup setValue
            input.change setValue
            @con.on 'change:value', =>
              current = @con.get 'value'
              unless current is @cast input.val()
                input.val(current).change()

            if @path.isAttribute()
              @provideSuggestions(input)

        provideSuggestions: (input) ->
          clone = @query.clone()
          pstr = @path.toString()
          value = @con.get('value')
          clone.constraints = (c for c in clone.constraints when not (c.path is pstr and c.value is value))

          filtering = clone.filterSummary pstr, "", intermine.options.MaxSuggestions
          filtering.done (items, stats) =>
            if items?.length > 0
              if items[0].item? # string-ish values.
                @handleSummary(input, items, stats.uniqueValues)
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
            if not currentOp and @con.has('type')
                @drawTypeOpts(fs)
            else if (@path.getType() in intermine.Model.BOOLEAN_TYPES) and not (currentOp in intermine.Query.NULL_OPS)
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
            @con.set op: (if @path.isReference() then 'LOOKUP' else '=')

        addIcons: ->

        valueChanged: (value) -> @fillConSummaryLabel _.extend({}, @con, {value: "" + value})

        opChanged: (op) -> @$('.label-op').text op

        removeConstraint: () -> # Nothing to do - just suppress this.

        hideEditForm: (e) ->
            super(e)
            @query.trigger "cancel:add-constraint"
            @remove()

    scope "intermine.query", {ActiveConstraint, NewConstraint}
