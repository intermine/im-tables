_ = require 'underscore'
$ = require 'jquery'
fs = require 'fs'

{Promise} = require 'es6-promise'

# Support
Messages = require '../messages'
Icons = require '../icons'
Options = require '../options'
View = require '../core-view'
ConstraintSummary = require './constraint-summary'

html = fs.readFileSync __dirname + '/../templates/active-constraint.html', 'utf8'
ACTIVE_CONSTRAINT_TEMPLATE = _.template html, variable: 'data'

{Query, Model} = require 'imjs'

# Operator sets
{REFERENCE_OPS, LIST_OPS, MULTIVALUE_OPS, NULL_OPS, ATTRIBUTE_OPS, ATTRIBUTE_VALUE_OPS} = Query
{NUMERIC_TYPES, BOOLEAN_TYPES} = Model

BASIC_OPS = ATTRIBUTE_VALUE_OPS.concat NULL_OPS

# It is very important that the placeholder get set for the appropriate mine value.
Messages.set
  'conbuilder.Update': 'Update'
  'conbuilder.Cancel': 'Cancel'
  'conbuilder.NotEditable': 'This constraint is not editable'
  'conbuilder.ValuePlaceholder': 'David*'
  'conbuilder.ExtraPlaceholder': 'Wernham-Hogg'
  'conbuilder.ExtraLabel': 'in'
  'conbuilder.IsA': 'is a'
  'conbuilder.NoValue': 'No value selected. Please enter a value.'
  'conbuilder.Duplicate': 'This constraint is already on the query'
  'conbuilder.TooManySuggestions': 'We cannot show you all the possible values'
  'conbuilder.NoSuitableLists': 'No lists of this type are available'
  'conbuilder.NoSuitableLoops': 'No suitable loop paths were found'

MULTI_TD_INPUTS = '.im-multi-value-table input'

TOO_MANY_SUGGESTIONS_TEMPL = _.template """
  <span class="alert alert-info">
    <i class="icon-info-sign"></i>
    <%- messages.getText('conbuilder.TooManySuggestions') %>
    There are <%= extra %> values we could not include.
  </span>
"""

TOO_MANY_SUGGESTIONS = (data) -> TOO_MANY_SUGGESTIONS_TEMPL _.extend {messages: Messages}, data

PATH_SEGMENT_DIVIDER = "&rarr;"

class SuggestionSource

  tooMany: '<span></span>'

  constructor: (@suggestions, @total) ->
    maxSuggestions = Options.get('MaxSuggestions')
    if @total > maxSuggestions
      @tooMany = TOO_MANY_SUGGESTIONS extra: total - MaxSuggestions

  suggest: (term, cb) =>
    parts = (term?.toLowerCase()?.split(' ') ? [])
    matches = ({item}) ->
      item ?= ''
      _.all parts, (p) -> item.toLowerCase().indexOf(p) >= 0
    cb(s for s in @suggestions when matches s)

aeql = (xs, ys) ->
  if not xs and not ys
    return true
  if not xs or not ys
    return false
  [shorter, longer] = _.sortBy [xs, ys], (a) -> a.length
  _.all longer, (x) -> x in shorter

basicEql = (a, b) ->
  return a is b unless (a and b)
  keys = _.union.apply _, [a, b].map _.keys
  same = true
  for k in keys
    [va, vb] = (x[k] for x in [a, b])
    same and= (if _.isArray va then aeql va, vb else va is vb)
  return same

NO_OP = ->

# PathInfo -> Promise<{path :: String, name :: String}>
toNamedPath = (p) -> p.getDisplayName().then (name) ->
  {path: p.toString(), name}

ATTRIBUTE_VALUE_TEMPL = """
  <input class="span7 form-control im-constraint-value im-value-options im-con-value im-con-value-attr"
         type="text"
         placeholder="<%- messages.getText('conbuilder.ValuePlaceholder') %>"
         value="<%- con.value %>">
"""

EXTRA_VALUE_TEMPL = """
  <label class="im-value-options">
    <%- messages.getText('conbuilder.ExtraLabel') %>
    <input type="text" class="im-extra-value form-control"
          placeholder="<%- messages.getText('conbuilder.ExtraPlaceholder') %>"
          value="<%- con.value %>">
  </label>
"""

trim = (s) -> String(s).replace(/^\s+/, '').replace(/\s+$/, '')

numify = (x) -> 1 * trim x

module.exports = class ActiveConstraint extends View

  tagName: "form"

  className: "form-inline im-constraint row-fluid"

  initialize: ({@query, @constraint}) ->
    super
    @typeaheads = []
    @sliders = []
    @path = @query.getPathInfo @constraint.path
    @type = @path.getType()
    @cast = if @type in NUMERIC_TYPES then numify else trim
    @model.set @constraint

    @ops = if @path.isReference() or @path.isRoot()
      REFERENCE_OPS
    else if @path.getType() in BOOLEAN_TYPES
      ["=", "!="].concat(NULL_OPS)
    else if @model.has('values') # Attribute.
      ATTRIBUTE_OPS
    else
      BASIC_OPS

    @listenTo @model, 'change:op', @setValueData
    @listenTo @model, 'change:type', @setTypeName

    # Declare rendering dependency on messages and icons.
    @listenTo Messages, 'change', @reRender
    @listenTo Icons, 'change', @reRender
    # Clean up sliders and typeaheads
    @listenTo @query, 'cancel:add-constraint', @removeWidgets

    @path.getDisplayName (error, displayName) => @model.set {error, displayName}
    @setValueData()
    @setTypeName()

  setTypeName: ->
    type = @model.get 'type'
    if not type?
      @model.unset 'typeName'
    else
      @query.model.makePath(type)
            .getDisplayName (error, typeName) => @model.set {error, typeName}

  events: ->
    'change .im-ops': 'setOperator'
    'change .im-multi-value-table input': 'setMultiValues'
    'click .im-multi-value-table td': 'toggleRowCheckbox'
    'click .im-value-options .im-true': 'setValueTrue'
    'click .im-value-options .im-false': 'setValueFalse'
    'click .im-edit': 'toggleEditForm'
    'click .btn-cancel': 'hideEditForm'
    'click .btn-primary': 'editConstraint'
    'click .im-remove-constraint': 'removeConstraint'
    'change .im-value-type': 'setType'
    'change .im-con-value-list': 'setList'
    'change .im-extra-value': 'setExtraValue'
    'change .im-con-value-attr': 'setAttributeValue'
    'submit': (e) -> e.preventDefault(); e.stopPropagation()

  setOperator: -> @model.set op: @$('.im-ops').val()

  setType: -> @model.set type: @('.im-value-type').val()

  setValueTrue: -> @model.set value: true

  setValueFalse: -> @model.set value: false

  setList: -> @model.set value: @$('.im-con-value-list').val()

  setExtraValue: -> @model.set extraValue: @$('input.im-extra-value').val()

  readAttrValue: ->
    raw = @$('.im-con-value-attr').val()
    try
      @cast raw # to string or number, as per path type
    catch e
      @model.set error: new Error("#{ raw } might not be a legal value for #{ @path }")
      raw

  setAttributeValue: -> @model.set value: @readAttrValue()

  setMultiValues: (e) ->
    e?.stopPropagation() # prevent handling by toggleRowCheckbox
    vals = @$(MULTI_TD_INPUTS).filter(':checked').map(-> @getAttribute 'data-value').get()
    @model.set values: vals

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
    @model.set @constraint
    @removeTypeAheads()

  removeTypeAheads: ->
    while (ta = @typeaheads.shift())
      ta.off('typeahead:selected')
      ta.off('typeahead:autocompleted')
      ta.typeahead('destroy')
      ta.remove()

  removeSliders: ->
    while (sl = @sliders.shift())
      sl.slider('destroy')
      sl.remove()

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

      @removeTypeAheads()
      true

  removeConstraint: (e, silently = false) ->
      @query.removeConstraint @constraint, silently

  buttons: -> [
      {
          key: "conbuilder.Update",
          classes: "btn btn-primary"
      },
      {
          key: "conbuilder.Cancel",
          classes: "btn btn-cancel"
      }
  ]

  isTypeConstraint: -> @path.isReference() and (not @model.get 'op') and @model.has('type')

  # TODO - extract sub-view

  getOtherOperators: -> _.without @ops, @model.get 'op'

  getData: ->
    buttons = @buttons()
    messages = Messages
    icons = Icons
    otherOperators = @getOtherOperators()
    con = @model.toJSON()
    {buttons, icons, messages, icons, otherOperators, con}

  template: (data) ->
    # Hook in here to supply a sub-template based on the operator.
    console.debug(data)
    if data.con.valueData?
      data.valueTemplate = @getValueTemplate()
      data.valueData = data.con.valueData
    else
      data.valueTemplate = -> # No-op while we wait for results.
    ACTIVE_CONSTRAINT_TEMPLATE data

  render: ->
    @removeWidgets()
    super
    @renderChild 'summary', (new ConstraintSummary {@model}), @$ '.im-con-overview'
    if @path.isAttribute() and @model.get('op') in ATTRIBUTE_VALUE_OPS
      @provideSuggestions()
    this

  remove: -> # Make sure we clean up any type-aheads.
    @removeWidgets()
    super

  removeWidgets: ->
    @removeTypeAheads()
    @removeSliders()

  # Data provider and template for type constraints.

  getPossibleTypes: -> @__possible_types ?= do =>
    # get a promise for possible paths, cached so we don't have to keep going back to the model.
    type = @model.get('type')
    subclasses = @query.getSubclasses()
    schema = @query.model
    delete subclasses[@path] # no point unless we unconstrain it
    baseType = schema.getPathInfo(@path, subclasses).getType()
    paths = (schema.makePath t for t in schema.getSubclassesOf baseType)
    Promise.all paths.map toNamedPath

  typeOptsTempl: _.template """
    <label class="span4">
      <%- messages.getText('conbuilder.IsA') %>
    </label>
    <select class="span7 im-value-type">
      <% valueData.forEach(function (type) { %>
        <option
          value="<%= type.path %>"
          <%= (type.path === con.type) ? 'selected' : void 0 %>>
          <%- type.name %>
        </option>
      <% }); %>
    </select>
  """

  # Template for boolean constraints.

  booleanOptsTempl: _.template """
    <div class="im-value-options btn-group">
      <button class="btn im-true <%= (con.value === true) ? ' active' : void 0 %>">
        True
      </button>
      <button class="btn im-false <%= (con.value === false) ? ' active' : void 0 %>">
        False
      </button>
    </div>
  """

  # Template for ONE OF / NONE OF
  #
  multiValueTempl: _.template """
    <div class="im-value-options im-multi-value-table">
      <table class="table table-condensed">
        <% valueData.forEach(function (value) { %>
          <tr>
              <td>
                <input type="checkbox"
                  <%= (~con.values.indexOf(value)) ? 'checked' : void 0 %>
                  data-value="<%- value %>">
              </td>
              <td class="im-multi-value"><%- value %></td>
          </tr>
        <% }); %>
      </table>
    </div>
  """

  valueSelect: """<select class="span7 im-value-options im-con-value"></select>"""

  clearer: '<div class="im-value-options" style="clear:both;">'

  # Template, data and handler for lists

  listTempl: _.template """
    <select class="span7 im-value-options im-con-value im-con-value-list">
      <% if (valueData.length) { %>
        <% valueData.forEach(function (list) { %>
          <option <%= (list.name === con.value) ? 'selected' : void 0 %> value="<%- list.name %>">
            <%- list.name %> (<%- list.size %> <%- list.typeName %>s)
          </option>
        <% }); %>
      <% } else { %>
        <%- messages.getText('conbuilder.NoSuitableLists') %>
      <% } %>
    </select>
  """

  getSuitableLists: -> # Cache this result, since we don't want to keep fetching it.
    @__suitable_lists ?= @query.service.fetchLists().then (lists) =>
      selectables = (l for l in lists when l.size and @path.isa l.type)
      withDisplayNames = (l) => # Promise to add a typeName property to the list.
        p = @query.model.makePath l.type
        p.getDisplayName().then (typeName) -> _.extend l, {typeName}
      Promise.all selectables.map withDisplayNames

  # Template and data provider for LOOP constraints.

  loopTempl: _.template """
    <select class="span7 im-value-options im-con-value im-con-value-loop">
      <% if (valueData.length) { %>
        <% valueData.forEach(function (candidate) { %>
          <option <%= (candidate.path === con.value) ? 'selected' : void 0 %>
            value="<%- candidate.path %>">
            <%- candidate.name %>
          </option>
        <% }); %>
      <% } else { %>
        <%- messages.getText('conbuilder.NoSuitableLoops') %>
      <% } %>
    </select>
  """

  getLoopCandidates: -> @__loop_candidates ?= do => # Cache result, to avoid making redundant requests.
    loopCandidates = @query.getQueryNodes().filter (candidate) =>
      (candidate.isa @type) or (@path.isa candidate.getType())

    Promise.all loopCandidates.map toNamedPath

  provideSuggestions: -> @getSuggestions().then ({stats, results}) =>
    if results?.length
      if stats.max?
        @handleNumericSummary(stats)
      else
        @handleSummary(results, stats.uniqueValues)

  getSuggestions: -> @__suggestions ?= do =>
    clone = @query.clone()
    pstr = @path.toString()
    value = @model.get('value')
    maxSuggestions = Options.get('MaxSuggestions')
    clone.constraints = (c for c in clone.constraints when not (c.path is pstr and c.value is value))

    clone.summarise pstr, maxSuggestions

  # Here we supply the suggestions using typeahead.js
  # see: https://github.com/twitter/typeahead.js/blob/master/doc/jquery_typeahead.md
  handleSummary: (items, total) ->
    input = @$ '.im-con-value-attr'

    source = new SuggestionSource items, total

    opts =
      minLength: 1
      highlight: true
    dataset =
      name: 'summary_suggestions'
      source: source.suggest
      displayKey: 'item'
      templates:
        footer: source.tooMany

    input.attr(placeholder: suggestions[0]).typeahead opts, dataset
    # Need to see if this needs hooking up...
    # input.on 'typeahead:selected', (e, suggestion) =>
    # @model.set value: suggestion.item

    # Keep a track of it, so it can be removed.
    @typeaheads.push input

  handleNumericSummary: ({min, max, average}) ->
    isInt = @path.getType() in Model.INTEGRAL_TYPES
    step = if isInt then 1 else (max - min / 100)
    caster = if isInt then ((x) -> parseInt(x, 10)) else parseFloat
    input = @$ '.im-con-value-attr'
    fieldset = input.closest('fieldset')
    feildset.append @clearer
    $slider = $ '<div class="im-value-options">'
    $slider.appendTo(fieldset).slider
      min: min
      max: max
      value: (if @model.has('value') then @model.get('value') else caster average)
      step: step
      slide: (e, ui) -> input.val(ui.value).change()
    input.attr placeholder: caster average
    fieldset.append @clearer
    input.change (e) -> $slider.slider 'value', caster input.val()
    @sliders.push $slider

  # Template for handling attribute values.

  attributeValueTempl: _.template ATTRIBUTE_VALUE_TEMPL

  # Template for handling lookup constraints
 
  lookupTempl: _.template ATTRIBUTE_VALUE_TEMPL + EXTRA_VALUE_TEMPL

  setValueData: -> @getValueData().then (valueData) =>  @model.set {valueData}

  getValueData: ->
    currentOp = @model.get 'op'


    if @isTypeConstraint()
      return @getPossibleTypes()

    if currentOp in MULTIVALUE_OPS # Use original values so we don't loose state.
      return Promise.resolve (@constraint.values or [])

    if currentOp in LIST_OPS
      return @getSuitableLists()

    if @path.isReference() and (currentOp in ['=', '!='])
      return @getLoopCandidates()

    return Promise.resolve {} # Placeholder, not needed.

  getValueTemplate: ->
    currentOp = @model.get 'op'

    if currentOp in Query.TERNARY_OPS
      return @lookupTempl

    else if currentOp in MULTIVALUE_OPS
      return @multiValueTempl

    if currentOp in LIST_OPS
      return @listTempl

    if (@path.getType() in BOOLEAN_TYPES) and not (currentOp in NULL_OPS)
      return @booleanOptsTempl

    if @isTypeConstraint()
      return @typeOptsTempl

    if @path.isReference() and (currentOp in ['=', '!='])
      return @loopTempl

    # if @path.isReference() - then return rangeValueTempl

    if not (currentOp in NULL_OPS)
      return @attributeValueTempl

    return NO_OP # for NULL VALUE constraint, for example.

