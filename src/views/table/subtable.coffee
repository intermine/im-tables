_ = require 'underscore'

CoreView = require '../../core-view'
Options = require '../../options'
Collection = require '../../core/collection'
Templates = require '../../templates'
TypeAssertions = require '../../core/type-assertions'
NestedTableModel = require '../../models/nested-table'
PathModel = require '../../models/path'
SubtableSummary = require './subtable-summary'
SubtableInner = require './subtable-inner'

{ignore} = require '../../utils/events'

class PathCollection extends Collection

  model: PathModel

# A cell containing a subtable of other rows.
# The table itself can be expanded or collapsed.
# When collapsed it is represented by a summary line.
module.exports = class SubTable extends CoreView

  tagName: 'td'

  className: 'im-result-subtable'

  Model: NestedTableModel

  parameters: [
    'query',
    'cellify',
    'expandedSubtables'
  ]

  parameterTypes:
    query: TypeAssertions.Query
    cellify: TypeAssertions.Function
    expandedSubtables: TypeAssertions.Collection

  initialize: ->
    super
    @headers = new PathCollection
    @listenTo @expandedSubtables, 'add remove reset', @onChangeExpandedSubtables
    @buildHeaders()

  # getPath is part of the RowCell API
  getPath: -> @model.get 'column'

  initState: ->
    @state.set open: Options.get('Subtables.Initially.expanded')

  stateEvents: ->
    'change:open': @onChangeOpen

  onChangeOpen: ->
    wrapper = @el.querySelector '.im-table-wrapper'
    if @state.get('open')
      if @renderTable(wrapper) # no point in sliding down unless this returned true.
        @$(wrapper).slideDown()
    else
      @$(wrapper).slideUp()

  onChangeExpandedSubtables: ->
    @state.set open: @expandedSubtables.contains @getPath()

  events: ->
    'click .im-subtable-summary': @toggleTable

  toggleTable: -> @state.toggle 'open'

  template: Templates.template 'table-subtable'

  renderChildren: ->
    @renderChildAt '.im-subtable-summary', (new SubtableSummary {@model})
    @onChangeOpen()

  tableRendered: false

  # Render the table, and return true if there is anything to show.
  renderTable: (wrapper) ->
    rows = @model.get 'rows'
    return @tableRendered if (@tableRendered or (rows.length is 0))
    inner = new SubtableInner _.extend {rows}, (_.pick @, SubtableInner::parameters)

    @renderChild 'inner', inner, wrapper
    @tableRendered = true

  buildHeaders: ->
    [row] = @model.get('rows')
    return unless row? # No point building headers if the table is empty

    # Use the first row as a pattern.
    @headers.set(new PathModel c.get('column') for c in row)

