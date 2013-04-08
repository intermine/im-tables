do ->
  sendToGenomeSpace = ->
    genomeSpaceURL = intermine.options.GenomeSpaceUpload
    uploadUrl = @state.get 'url'
    format = @requestInfo.get 'format'

    fileName = "Results.#{ format.extension }"
    qs = $.param {uploadUrl, fileName}
    url  = "#{genomeSpaceURL}?#{qs}"

    win = window.open url

    win.setCallbackOnGSUploadComplete = (savePath) => @stop()
    win.setCallbackOnGSUploadError = (savePath) =>
      @trigger 'export:error', 'genomespace'
      @stop()

    win.focus()

  scope 'intermine.export.external.Genomespace',
    export: sendToGenomeSpace
    events: ->
      'click .im-send-to-genomespace': (e) => sendToGenomeSpace.call(@, e)
