do ->

  saveGalaxyPreference = (uri) -> @query.service.whoami (user) ->
      if user.hasPreferences and user.preferences['galaxy-url'] isnt uri
          user.setPreference 'galaxy-url', uri

  doGalaxy = (galaxy) ->
    query = @query
    console.log "Sending to #{ galaxy }"
    endpoint = @getExportEndPoint()
    format = @requestInfo.get 'format'
    qLists = (c.value for c in @query when c.op is 'IN')
    intermine.utils.getOrganisms query, (orgs) =>
        params =
            tool_id: 'flymine' # name of tool within galaxy that does uploads.
            organism: orgs.join(', ')
            URL: endpoint
            URL_method: "post"
            name: "#{ if orgs.length is 1 then orgs[0] + ' ' else ''}#{ query.root } data"
            data_type: if format.extension is 'tsv' then 'tabular' else format.extension
            info: """
                #{ query.root } data from #{ @service.root }.
                Uploaded from #{ window.location.toString().replace(/\?.*/, '') }.
                #{ if qLists.length then ' source: ' + lists.join(', ') else '' }
                #{ if orgs.length then ' organisms: ' + orgs.join(', ') else '' }
            """
        for k, v of @getExportParams()
            params[k] = v
        intermine.utils.openWindowWithPost "#{ galaxy }/tool_runner", "Upload", params

  changeGalaxyURI = (e) -> @requestInfo.set galaxy: @$('.im-galaxy-uri').val()

  forgetGalaxy = (e) ->
    @service
      .whoami()
      .pipe( (user) => console.log(user); user.clearPreference('galaxy-url'))
      .done( () => @requestInfo.set galaxy: intermine.options.GalaxyMain )
    return false

  sendToGalaxy = ->
    uri = @requestInfo.get 'galaxy'
    doGalaxy.call @, uri
    if @$('.im-galaxy-save-url').is(':checked') and uri isnt intermine.options.GalaxyMain
        saveGalaxyPreference.call @, uri

  scope 'intermine.export.external.Galaxy',
      export: sendToGalaxy
      init: ->
        @requestInfo.set galaxy: intermine.options.GalaxyMain
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

