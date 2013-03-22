do ->
  sendToGenomeSpace = ->
    genomeSpaceURL = intermine.options.GenomeSpaceUpload
    uploadUrl = @state.get 'url'
    fileName = "Results.#{ @requestInfo.get 'format' }"
    qs = $.param {uploadUrl, fileName}

    w = @$('.modal-body').width()
    h = Math.max 400, @$('.modal-body').height()

    console.log w, h

    console.log uploadUrl
    console.log fileName
    console.log qs

    gsFrame = @$('.gs-frame').attr
      src: genomeSpaceURL + '?' + qs
      width: w
      height: h

    @$('.btn-primary').addClass 'disabled'

    @$('.carousel').carousel interval: false
    @$('.carousel').carousel 1

    window.setCallbackOnGSUploadComplete = (savePath) =>
      @$('.carousel').carousel 0
      @$('.carousel').carousel 'pause'
      @$('.btn-primary').removeClass 'disabled'
      @stop()

  scope 'intermine.export.external.Genomespace',
    export: sendToGenomeSpace
    events: ->
      'click .im-send-to-genomespace': (e) => sendToGenomeSpace.call(@, e)
