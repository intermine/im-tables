# Define expectations
#

root = exports ? this

unless root.console
    root.console =
        log: ->
        debug: ->
        error: ->


root.intermine ?= {}
root.intermine.query ?= {}

intermine = root.intermine

class intermine.query.ActiveConstraint extends Backbone.View
    tagName: "form"
    className: "form-inline im-constraint row-fluid"
    
    initialize: (@query, @con) ->
        @type = @query.service.model.getCdForPath @con.path
        if @type
            @ops = intermine.Query.REFERENCE_OPS
        else
            @ops = intermine.Query.ATTRIBUTE_OPS

    events:
        'change .im-ops': 'drawValueOptions'
        'click .icon-edit': 'toggleEditForm'
        'click .btn-cancel': 'hideEditForm'
        'click .btn-primary': 'editConstraint'
        'click .icon-remove-sign': 'removeConstraint'

    toggleEditForm: ->
        @$('.im-con-overview').siblings().slideToggle 200

    hideEditForm: ->
        @$('.im-con-overview').siblings().slideUp 200
    editConstraint: ->
    removeConstraint: ->
        @query.removeConstraint @con

    render: ->
        $label = $ """
            <label class="im-con-overview">
                <span class="im-con-summary span9">
                  #{@con.title or @con.path.replace(/^[^\.]+\.?/, "")} 
                  #{if @con.op is "=" then ":" else (@con.op or "is a")}
                  #{if @con.values then @con.values.length + " values" else @con.value or @con.type or ""}
                </span>
                <i class="icon-remove-sign"></i>
            </label>
        """
        @$el.append $label
        fs = $("""<fieldset class="im-constraint-options"></fieldset>""").appendTo @el
        if @con.locked
            $label.append """<i class="icon-lock" title="this constraint is not editable"></i>"""
        else
            $label.append """<i class="icon-edit"></i>"""
        $select = $ """<select class="span4 im-ops"><option>#{ @con.op }</option></select>"""
        $select.appendTo fs
        _(@ops).chain().without(@con.op).each (op) -> $select.append """<option>#{ op }</select>"""
        @drawValueOptions()
        @$el.append """
            <div class="btn-group">
                <button type="submit" class="btn btn-primary">Apply</button>
                <button class="btn btn-cancel">Cancel</button>
            </div>
        """
        this

    drawValueOptions: ->
        @$('.im-value-options').remove()
        fs = @$('.im-constraint-options')
        op = @$('.im-ops').val()
        if op in intermine.Query.MULTIVALUE_OPS
            values = @con.values or []
            $multiValues = $('<table class="table table-condensed im-value-options"></table>').appendTo fs
            _(values).each (v) -> $multiValues.append """
                <tr>
                    <td><input type=checkbox checked></td>
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


