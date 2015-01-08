CoreView = require '../../core-view'
Templates = require '../../templates'
Icons = require '../../icons'

sortQueryByPath = require '../../utils/sort-query-by-path'

INITIAL_CARETS = /^\s*>\s*/

# An individual path we can sort by.
class SortedPath extends CoreView

  tagName: 'li'

  className: 'im-formatted-path im-subpath'

  # Inherits model and state from parent, but is specialised on @path
  initialize: ({@query, @path}) ->
    @listenTo @state, 'change', @reRender
    super

  getData: -> # Provides Icons, name, direction
    names = @state.toJSON()
    name = names[@path]?.replace name.group, ''
                        .replace INITIAL_CARETS, ''
    direction = @query.getSortDirection @path
    {Icons, name, direction}

  template: Templates.template 'formatted_sorting'

  events: -> click: 'sortByPath'

  sortByPath: -> sortQueryByPath @query, @path

