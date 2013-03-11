do ->

    class OuterJoinDropDown extends Backbone.View
        className: "im-summary-selector"
        tagName: 'ul'

        initialize: (@query, @path) ->

        render: ->
            vs = []
            node = @path
            if !@path.isAttribute()
                str = @path.toString()
                vs = (v for v in @query.views when v.match str)
            else
                node = parent = @path.getParent()
                formatter = intermine.results.getFormatter @path
                if replaces = formatter?.replaces
                  prefix = parent + '.'
                  vs = (prefix + r for r in replaces)
                else
                  f  = (a) -> intermine.options.ShowId or a isnt 'id'
                  as = (name for name, a of parent.getEndClass().attributes when f name)
                  vs = (parent.append(a).toString() for a in as)

            if vs.length is 1
                @showPathSummary(vs[0])
            else
                for v in vs then do (v) =>
                  li = $ """<li class="im-outer-joined-path"><a href="#"></a></li>"""
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

    class DropDownColumnSummary extends Backbone.View
        className: "im-dropdown-summary"

        initialize: (@query, @view) ->
          @$el.on 'destroyed', @close

        remove: ->
          console.log "Byeee...."
          @heading?.remove()
          @summ?.remove()
          super()

        render: ->
            heading = new SummaryHeading(@query, @view)
            heading.render().$el.appendTo @el
            @heading = heading

            @summ = new intermine.results.ColumnSummary(@query, @view)
            @summ.noTitle = true
            @summ.render().$el.appendTo @el

            this

    class SummaryHeading extends Backbone.View

        nts = (num) -> intermine.utils.numToString(num, ',', 3)

        initialize: (@query, @view) ->
            @query.on "got:summary:total", (path, total, got, filteredTotal) =>
                if path is @view
                    available = filteredTotal ? total
                    @$('.im-item-available').text nts available
                    @$('.im-item-total').text(if filteredTotal? then "(filtered from #{ nts total })" else "")

        template: _.template """
            <h3>
                <span class="im-item-got"></span>
                <span class="im-item-available"></span>
                <span class="im-type-name"></span>
                <span class="im-attr-name"></span>
                <span class="im-item-total"></span>
            </h3>
        """

        render: ->
            @$el.append @template()

            s = @query.service
            type = @query.getPathInfo(@view).getParent().getType().name
            attr = @query.getPathInfo(@view).end.name

            s.get("model/#{type}").then (info) =>
                @$('.im-type-name').text info.name

            s.get("model/#{type}/#{attr}").then (info) =>
                @$('.im-attr-name').text intermine.utils.pluralise(info.name)

            this
        
    scope "intermine.query.results", {OuterJoinDropDown, DropDownColumnSummary}
