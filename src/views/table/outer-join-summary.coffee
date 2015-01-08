CoreView = require '../../core-view'

# FIXME FIXME FIXME
module.exports = class OuterJoinDropDown extends CoreView

  className: "im-summary-selector no-margins"

  tagName: 'ul'

  initialize: ({@query}) ->
    super
    {@replaces, @isFormatted, @path} = @model.toJSON()

  getSubpaths: -> @replaces.slice()

  render: ->
    vs = []
    node = @path
    vs = @getSubpaths()

    if vs.length is 1
      @showPathSummary(vs[0])
    else
      for v in vs then do (v) =>
        li = $ """<li class="im-subpath im-outer-joined-path"><a href="#"></a></li>"""
        @$el.append li
        $.when(node.getDisplayName(), @query.getPathInfo(v).getDisplayName()).done (parent, name) ->
          li.find('a').text name.replace(parent, '').replace(/^\s*>\s*/, '')
        li.click (e) =>
          e.stopPropagation()
          e.preventDefault()
          @showPathSummary(v)
    this

  showPathSummary: (v) ->
    summ = new intermine.query.results.DropDownColumnSummary(@query, v)
    @$el.parent().html(summ.render().el)
    @summ = summ
    @$el.remove() # Detach, but stay alive so we can remove summ later.

  remove: ->
    @summ?.remove()
    super()
