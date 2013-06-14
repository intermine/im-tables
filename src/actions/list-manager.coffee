define 'actions/list-manager', using 'actions/list-append-dialogue', 'actions/new-list-dialogue', (ListAppender, ListCreator) ->

  class ListManager extends Backbone.View
    tagName: "li"
    className: "im-list-management dropdown"

    initialize: (@states) ->
      @states.on 'add reverted', @updateTypeOptions
      @action = ListManager.actions.create

      @disabled = not @states.currentQuery.service.token?

    html: """
        <a href="#" class="btn" data-toggle="dropdown">
            <i class="icon-list-alt"></i>
            <span class="im-only-widescreen">Create / Add to</span>
            List
            <b class="caret"></b>
        </a>
        <ul class="dropdown-menu im-type-options pull-right">
            <div class="btn-group" data-toggle="buttons-radio">
                <button class="btn active im-list-action-chooser" data-action="create">
                    Create New List
                </button>
                <button class="btn im-list-action-chooser" data-action="append">
                    Add to Existing List
                </button>
            </div>
        </ul>
    """

    events:
      'click .btn-group > .im-list-action-chooser': 'changeAction'
      'click .im-pick-and-choose': 'startPicking'

    @actions:
      create: ListCreator
      append: ListAppender

    changeAction: (e) =>
      e.stopPropagation()
      e.preventDefault()
      $t = $(e.target).button "toggle"
      @action = ListManager.actions[ $t.data 'action' ]

    openDialogue: (type, q) ->
      dialog = new @action(@states.currentQuery)
      dialog.render().$el.appendTo @el
      dialog.openDialogue type, q

    startPicking: ->
      dialog = new @action(@states.currentQuery)
      dialog.render().$el.appendTo @el
      dialog.startPicking()

    descendedFrom = (putativeParent) ->
      if putativeParent.isAttribute()
        -> false
      else
        prefix = putativeParent + '.'
        (suspectedChild) -> suspectedChild.substring(0, prefix.length) is prefix
    
    pathOf = intermine.funcutils.get 'path'

    updateTypeOptions: =>
      ul = @$ '.im-type-options'
      ul.find("li").remove()

      query = @states.currentQuery

      viewNodes = query.getViewNodes()

      for node in viewNodes then do (node) =>
          li = $ """<li></li>"""
          ul.append li
          countQuery = query.clone()
          try
              countQuery.select [node.append("id").toPathString()]
          catch err
              console.error(err)
              return

          # Must de-outer counts on outer-joined paths.
          if query.isOuterJoined(countQuery.views[0]) then do (path = node) ->
            style = 'INNER'
            until path.isRoot()
              countQuery.addJoin {path, style}
              path = path.getParent()

          unselected = viewNodes.filter (n) -> n isnt node

          for missingNode in unselected
              inCons = _.any countQuery.constraints, _.compose descendedFrom(missingNode), pathOf
              needsAsserting = (not inCons) or (query.isOuterJoined(missingNode))
              if needsAsserting
                  countQuery.addConstraint( [missingNode.append("id"), "IS NOT NULL"] )

          countQuery.orderBy []

          li.click => @openDialogue(node.getType().name, countQuery)
          li.mouseover -> query.trigger "start:highlight:node", node
          li.mouseout -> query.trigger "stop:highlight"

          countQuery.count().fail((err) -> console.error("#{ countQuery.toXML() } failed", err)).then (n) ->
              return li.remove() if n < 1

              quantifier = switch n
                  when 1 then "The"
                  when 2 then "Both"
                  else "All #{n}"
              typeName = intermine.utils.pluralise(node.getType().name, n)
              
              li.append """
                  <a href="#">
                      #{quantifier} #{typeName}
                  </a>
              """

      ul.append """
        <li class="im-pick-and-choose">
            <a href="#">Choose individual items from the table</a>
        </li>
      """

    render: ->
      @$el.append @html
      @updateTypeOptions()
      this

