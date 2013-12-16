Backbone = require 'backbone'

ROW = """<li class="im-formatted-part im-subpath"><a><i class="sort-icon"></i></a></li>"""
INIT_CARETS = /^\s*>\s*/
ICONS = ->
  ASC: intermine.css.sortedASC
  DESC: intermine.css.sortedDESC
  NONE: intermine.css.unsorted
NEXT_DIRECTION_OF =
  ASC: 'DESC'
  DESC: 'ASC'
  NONE: 'ASC'

class exports.FormattedSorting extends Backbone.View

  className: 'im-col-sort-menu no-margins'
  tagName: 'ul'

  initialize: (@query, @path, @model) ->

  toggleSort: (paths) ->
    console.log "Ordering by #{ paths }"
    currentDir = @currentDir paths
    direction = NEXT_DIRECTION_OF[ currentDir ]
    @query.orderBy ( {path, direction} for path in paths )
    @model.set {direction}
    @remove()

  currentDir: (paths) ->
    dirs = (@query.getSortDirection p for p in paths)
    current = dirs[0] if _.unique(dirs).length is 1
    current ? 'NONE'

  render: ->
    console.log "Rendering FormattedSorting for #{ @path }"
    paths = []
    replaces = @model.get('replaces')
    if replaces.length > 1
      paths = [replaces].concat replaces.map (x) -> [x]
    else
      paths = [@path]

    if paths.length is 1
      @toggleSort paths[0]
    else
      paths.forEach @appendSortOption

    this

  appendSortOption: (paths) =>
    li = $ ROW
    $a = li.find 'a'
    icons = ICONS()

    for p in paths then do (p) =>
      console.log "Adding span for #{ p }"
      $span = $ """<span class="im-sort-path">"""
      $a.append $span
      path = @query.getPathInfo p
      $.when(@path.getDisplayName(), path.getDisplayName()).done (pn, cn) ->
        $span.text cn.replace(pn, '').replace(INIT_CARETS, '')

    $a.click (e) =>
      e.stopPropagation()
      e.preventDefault()
      @toggleSort paths

    currentDir = if paths is @model.get('replaces')
      @currentDir paths
    else if @currentDir(@model.get('replaces')) isnt 'NONE'
      'NONE'
    else
      @currentDir paths

    li.find('i').addClass icons[ currentDir ]

    @$el.append li
    return null
