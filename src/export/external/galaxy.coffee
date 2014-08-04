do ->

  yielding = (x) -> $.Deferred(-> @resolve x).promise()

  # (Query) -> Promise<String>
  getResultClass = (q) -> $.when(q).then (query) ->
    viewNodes = query.getViewNodes()
    {model} = query
    if viewNodes.length is 1
      model.getPathInfo(viewNodes[0].getType().name).getDisplayName()
    else if commonType = model.findCommonType(node.getType() for node in viewNodes)
      model.getPathInfo(commonType).getDisplayName()
    else if model.name
      yielding model.name
    else
      yielding ''
  
  saveGalaxyPreference = (uri) -> @query.service.whoami (user) ->
      if user.hasPreferences and user.preferences['galaxy-url'] isnt uri
          user.setPreference 'galaxy-url', uri

  doGalaxy = (galaxy) ->
    uri = if /tool_runner/.test(galaxy) then galaxy else "#{ galaxy }/tool_runner"
    query = @getExportQuery()
    endpoint = @getExportEndPoint()
    format = @requestInfo.get 'format'
    qLists = (c.value for c in @query when c.op is 'IN')
    $.when(intermine.utils.getOrganisms(query), getResultClass(query)).then (orgs, type) =>
        prefix = if orgs.length is 1 then orgs[0] + ' ' else ''
        brand = intermine.options.brand[@service.root.replace(/\/[^\.]+$/, '')]
        suffix = if brand? then " from #{ brand }" else ''
        name = prefix + "#{ type } data" + suffix

        params =
            tool_id: intermine.options.GalaxyTool
            organism: orgs.join(', ')
            URL: endpoint
            URL_method: "post"
            name: name
            data_type: if format.extension is 'tsv' then 'tabular' else format.extension
            info: """
                #{ query.root } data from #{ @service.root }.
                Uploaded from #{ window.location.toString().replace(/\?.*/, '') }.
                #{ if qLists.length then ' source: ' + lists.join(', ') else '' }
                #{ if orgs.length then ' organisms: ' + orgs.join(', ') else '' }
            """
        @getExportParams().then (ep) ->
          for k, v of ep
            params[k] = v
          intermine.utils.openWindowWithPost uri, "Upload", params

  changeGalaxyURI = (e) -> @requestInfo.set galaxy: @$('.im-galaxy-uri').val()

  defaultGalaxy = -> intermine.options.GalaxyCurrent ? intermine.options.GalaxyMain

  forgetGalaxy = (e) ->
    @service.whoami().then( (user) => user.clearPreference 'galaxy-url' ).done =>
        @requestInfo.set galaxy: defaultGalaxy()
    return false

  sendToGalaxy = ->
    uri = @requestInfo.get 'galaxy'
    doGalaxy.call @, uri
    if @$('.im-galaxy-save-url').is(':checked') and uri isnt intermine.options.GalaxyMain
        saveGalaxyPreference.call @, uri

  scope 'intermine.export.external.Galaxy',
      export: sendToGalaxy
      init: ->
        @requestInfo.set galaxy: defaultGalaxy()
        @dummyParams.push 'galaxy'
        @service.whoami (user) =>
          if user.hasPreferences and (myGalaxy = user.preferences['galaxy-url'])
            @requestInfo.set galaxy: myGalaxy
        @requestInfo.on "change:galaxy", (m, uri) =>
          input = @$('input.im-galaxy-uri')
          currentVal = input.val()
          input.val(uri) unless currentVal is uri
          @$('.im-galaxy-save-url').attr disabled: uri is intermine.options.GalaxyMain
      events: ->
        'click .im-forget-galaxy': (e) => forgetGalaxy.call(@, e)
        'change .im-galaxy-uri': (e) => changeGalaxyURI.call(@, e)
        'click .im-send-to-galaxy': (e) => sendToGalaxy.call(@, e)

