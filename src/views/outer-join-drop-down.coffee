Backbone = require 'backbone'

{DropDownColumnSummary} = require './drop-down-column-summary'

class exports.OuterJoinDropDown extends Backbone.View
    className: "im-summary-selector no-margins"
    tagName: 'ul'

    initialize: (@query, @path, model) ->
      {@replaces, @isFormatted} = model.toJSON()

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
        summ = new DropDownColumnSummary(@query, v)
        @$el.parent().html(summ.render().el)
        @summ = summ
        @$el.remove() # Detach, but stay alive so we can remove summ later.

    remove: ->
      @summ?.remove()
      super()

