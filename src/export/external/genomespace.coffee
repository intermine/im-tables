do ->
  sendToGenomeSpace = ->
    genomeSpaceURL = intermine.options.GenomeSpaceUpload
    uploadUrl = @state.get 'url'
    {format, gsFileName} = @requestInfo.toJSON()

    fileName = "#{ gsFileName}.#{ format.extension }"
    qs = $.param {uploadUrl, fileName}
    url  = "#{genomeSpaceURL}?#{qs}"

    win = window.open url

    win.setCallbackOnGSUploadComplete = (savePath) => @stop()
    win.setCallbackOnGSUploadError = (savePath) =>
      @trigger 'export:error', 'genomespace'
      @stop()

    win.focus()

  scope 'intermine.export.external.Genomespace',
    init: ->
      view = @
      onChange = ->
        {format, gsFileName} = view.requestInfo.toJSON()
        view.$('.im-genomespace .im-format').text '.' + format.extension
        view.$('.im-genomespace-filename').val gsFileName

      @dummyParams.push 'gsFileName'
      @requestInfo.on 'change', onChange

      s = (@service.name or @service.root.replace(/^https?:\/\//, '').replace /\/.*/, '')

      gsFileName = "#{ @query.root } results from #{ s } #{ new Date() }"

      @requestInfo.set {gsFileName}

    export: sendToGenomeSpace
    events: ->
      'click .im-send-to-genomespace': (e) => sendToGenomeSpace.call(@, e)
      'change .im-genomespace-filename': (e) => @requestInfo.set gsFileName: $(e.target).val()
