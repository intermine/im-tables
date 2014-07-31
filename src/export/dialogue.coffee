define 'export/dialogue', using 'perma-query', (getPermaQuery) ->

  defer = (x) -> new jQuery.Deferred -> @resolve x

  EXPORT_FORMATS = [
      {name: "Spreadsheet (tab separated values)", extension: "tsv", param: "tab"},
      {name: "Spreadsheet (comma separated values)", extension: "csv"},
      {name: "XML", extension: "xml"},
      {name: "JSON", extension: "json"},
  ]

  BIO_FORMATS = [
      {
        name: "GFF3 (General Feature Format)",
        extension: "gff3",
        types: ["SequenceFeature"]
      },
      {
        name: "UCSC-BED (Browser Extensible Display Format)",
        extension: "bed", types: ["SequenceFeature"]
      },
      {name: "FASTA sequence", extension: "fasta", types: ["SequenceFeature", "Protein"]}
  ]

  DELENDA = [
      'requestInfo', 'state', 'exportedCols', 'possibleColumns',
      'seqFeatures', 'fastaFeatures', 'extraAttributes'
  ]

  ENTER = 13
  SPACE = 32

  formatByExtension = (ext) -> _.find EXPORT_FORMATS.concat(BIO_FORMATS), (f) -> f.extension is ext

  toPath = (col) -> col.get 'path'
  idAttr = (path) -> path.append 'id'
  isIncluded = (col) -> col.get('included')
  isntExcluded = (col) -> not col.get('excluded')
  featuresToPaths = (features) -> features.filter(isIncluded).map(_.compose idAttr, toPath)
  
  isImplicitlyConstrained = (q, node) ->
    return true if q.isInView node
    n = node.toString()
    for v in q.views
      return true if 0 is v.indexOf n
    for c in q.constraints
      return true if c.op and 0 is c.path.indexOf n
    return false

  anyAny = (xs, ys, f) -> _.any xs, (x) -> _.any ys, (y) -> f x, y

  anyNodeIsSuitable = (model, nodes) -> (types) -> anyAny types, nodes, (t, n) ->
    n.name in model.getSubclassesOf t

  {Tab} = intermine.bootstrap

  class ExportDialogue extends Backbone.View

      tagName: 'div'
      className: "modal im-export-dialogue"

      initialize: (query) ->
          @query = query.clone() # Take a snapshot, not a reference.
          @service = query.service
          @dummyParams = ['allRows', 'allCols', 'end', 'columnHeaders']
          @qids = {}
          @requestInfo = new Backbone.Model
            format: EXPORT_FORMATS[0]
            allRows: true
            allCols: true
            start: 0
            compress: "no"
            columnHeaders: true

          for name, enabled of intermine.options.ExternalExportDestinations when enabled
            intermine.export.external[name].init?.call(@)

          @state = new Backbone.Model destination: 'download-file'

          @state.on 'change:isPrivate', @onChangePrivacy
          @state.on 'change:url', @onChangeURL
          @state.on 'change:destination', @onChangeDest
          @state.on 'change:permalink', @onChangePermalink
          @state.on 'change:permaquery', @onChangePermaquery

          @service.fetchVersion (v) => @$('.im-ws-v12').remove() if v < 12

          @exportedCols = new Backbone.Collection
          @resetExportedColumns()

          @seqFeatures = new intermine.models.ClosableCollection
          @fastaFeatures = new intermine.models.ClosableCollection
          @extraAttributes = new intermine.models.ClosableCollection

          for col in [@seqFeatures, @fastaFeatures] then do (col) =>
            col.on 'change:included', => @onChangeIncludedNodes col

          @fastaFeatures.on 'change:included', (originator, incl) =>
            f = (m) -> m.set included: false unless m is originator
            @fastaFeatures.each f if incl

          @fastaFeatures.on 'change:included', (col, incl) =>
            canHaveExt = incl and col.get('path').isa('SequenceFeature')
            inp = @$('input.im-fasta-extension').attr disabled: not canHaveExt
            if canHaveExt
              @requestInfo.set extension: inp.val()
            else
              @requestInfo.unset 'extension'

          @extraAttributes.on 'change:included', =>
            extras = @extraAttributes.where included: true
            @requestInfo.set view: extras.map(toPath).map String

          @requestInfo.on 'change', @buildPermaLink
          @requestInfo.on 'change:format', @onChangeFormat, @
          @requestInfo.on 'change:format', @updateColTabText, @
          @requestInfo.on 'change:format', @updateFormatOptions, @
          @requestInfo.on 'change:start', (m, start) =>
              $elem = @$('.im-first-row')
              newVal = "#{start + 1}"
              if newVal isnt $elem.val()
                  $elem.val newVal
              @$slider?.slider 'option', 'values', [start, m.get('end') - 1 ]
          @requestInfo.on 'change:end', (m, end) =>
              $elem = @$('.im-last-row')
              newVal = "#{end}"
              if newVal isnt $elem.val()
                  $elem.val newVal
              @$slider?.slider 'option', 'values', [m.get('start'), end - 1 ]
          @requestInfo.on "change:format", (m, format) => @$('.im-export-format').val format
          @exportedCols.on 'add remove reset', @initCols
          @exportedCols.on 'add remove change:excluded', @updateColTabText, @
          @exportedCols.on 'add remove reset change:excluded', @buildPermaLink
          @requestInfo.on 'change:start change:end', =>
            {start, end} = @requestInfo.toJSON()
            text = if start is 0 and ((not end) or (@count and end is @count))
              "All rows"
            else
              "#{ end - start } rows"

            @$('.nav-tabs .im-export-rows').text text

      updateColTabText: ->
        n = @exportedCols.filter( (c) -> not c.get 'excluded').length
        @$('.nav-tabs .im-export-columns').text "#{ n } columns"

      onChangeIncludedNodes: (coll) ->
        n = coll.reduce ((n, m) -> n + if m.get('included') then 1 else 0), 0
        @$('.nav-tabs .im-export-columns').text "#{ n } nodes"
        @buildPermaLink()

      onChangeFormat: ->
        format = @requestInfo.get 'format'
        tab = @$ '.nav-tabs .im-export-format'
        tab.text "Format: #{ format.extension }"
        @$('.im-export-formats input').val [ format.extension ]
        @$('.im-format-choice').each ->
          inp = $('input', this)
          $(this).toggleClass 'active', inp.attr('value') is format.extension
      
      resetExportedColumns: (e) ->
        e?.stopPropagation()
        e?.preventDefault()
        @$('.im-reset-cols').addClass 'disabled'
        q = @query
        @exportedCols.reset q.views.map (v) -> path: q.getPathInfo v

      readColumnHeaders: (e) ->
        @requestInfo.set columnHeaders: $(e.target).is ':checked'

      readBedChrPrefix: (e) ->
        @requestInfo.set useChrPrefix: $(e.target).is ':checked'

      events: ->
        events =
          'click .im-reset-cols': 'resetExportedColumns'
          'click .im-col-btns': 'toggleColSelection'
          'click .im-row-btns': 'toggleRowSelection'
          'click .close': 'stop'
          'click .im-cancel': 'stop'
          'click a.im-download': 'export'
          'change .im-first-row': 'changeStart'
          'change .im-last-row': 'changeEnd'
          'keyup .im-range-limit': 'keyPressOnLimit'
          'submit form': 'dontReallySubmitForm'
          'click .im-perma-link': 'buildPermaLink'
          'click .im-perma-link-share': 'buildSharableLink'
          'click .im-download-file .im-collapser': 'toggleLinkViewer'
          'click .im-download-file .im-copy': 'copyUriToClipboard'
          'click .im-export-destinations > li > a': 'moveToSection'
          'hidden': 'modalHidden'
          'change .im-column-headers': 'readColumnHeaders'
          'change .im-bed-chr-prefix': 'readBedChrPrefix'
          'change .im-fasta-extension': 'readFastaExt'
          'click .im-download-file .im-what-to-show button': 'switchWhatToShow'
          'keyup .im-format-choice': (e) =>
            input = $(e.target).find('input')
            key = e?.which
            if key is ENTER or key is SPACE
              input.attr checked: true
              @requestInfo.set format: formatByExtension input.val()

        for format in EXPORT_FORMATS.concat(BIO_FORMATS) then do (format) =>
          key = "click .im-format-#{ format.extension }"
          cb = => @requestInfo.set {format}
          events[key] = cb
        for x in ['format', 'columns', 'rows', 'output', 'destination'] then do (x) =>
          key = "click .nav-tabs .im-export-#{ x }"
          cb = (e) =>
            $a = $(e.target)
            if $a.parent().is('.disabled')
              e.preventDefault()
              return false
            $a.data target: @$(".tab-pane.im-export-#{ x }")
            Tab.call $a, 'show'
          events[key] = cb

        for val in ["no", "gzip", "zip"] then do (val) =>
          events["click .im-#{val}-compression"] = (e) =>
            @requestInfo.set compress: val

        for name, enabled of intermine.options.ExternalExportDestinations when enabled
          moreEvents = intermine.export.external[name].events?.call(@)
          _.extend events, moreEvents if moreEvents?

        events
      
      readFastaExt: (e) ->
        ext = @$('input.im-fasta-extension').val()
        if ext and /\S/.test ext
          @requestInfo.set extension: ext
        else
          @requestInfo.unset 'extension'

      modalHidden: (e) ->
        # Could have been triggered by tooltip, or popover
        if e? and e.target is @el
          @remove()

      copyUriToClipboard: ->
        text = if @$('button.im-results-uri').is '.active'
          @$('.im-download').attr('href')
        else
          @$('.well.im-query-xml').text()

        window.prompt intermine.messages.actions.CopyToClipBoard, text

      toggleLinkViewer: ->
        @$('.im-download-file .im-perma-link-content').toggleClass 'hide show'
        @$('.im-download-file .im-collapser').toggleClass 'icon-angle-right icon-angle-down'

      moveToSection: (e) ->
        $this = $ e.currentTarget
        Tab.call $this, 'show'
        destination = $this.data 'destination'
        @state.set {destination}

      buildSharableLink: (e) ->
          # TODO!!
          @$('.im-perma-link-share-content').text("TODO")

      switchActive = ->
        $this = $ this
        $this.toggleClass 'active', not $this.hasClass 'active'

      switchWhatToShow: (e) ->
        return false if $(e.target).hasClass 'active'

        btns = @$ '.im-what-to-show button'
        btns.each switchActive

        wells = @$ '.im-export-destination-options .im-download-file .well'
        wells.each switchActive

      buildPermaLink: (e) =>
          endpoint = @getExportEndPoint()
          currentQuery = @query
          isPrivate = intermine.utils.requiresAuthentication currentQuery
          @state.set {isPrivate}
          # TODO: use the original query for actual export.
          for [noIds, prop] in [[true, 'permalink'], [false, 'url']] then do (noIds, prop) =>
            @getExportParams(noIds).then (params) =>
              delete params.token unless isPrivate
              url = endpoint + "?" + $.param(params, true)
              @state.set(permaquery: params.query) if noIds
              @state.set prop, url
              # Arbitrary long-uri cut off. Tests show failure starts around here.
              uriIsTooLong = url.length > 4000
              if uriIsTooLong
                @getExportQuery(noIds).then (eq) =>
                  xml = eq.toXML()
                  # Check our own cache first.
                  fetching = (@qids[xml] ?= eq.fetchQID())

                  fetching.done (qid) =>
                    @$('.im-long-uri').show()
                    delete params.query
                    params.qid = qid
                    url = endpoint + "?" + $.param(params, true)
                    @state.set prop, url
              else
                @$('.im-long-uri').hide()



      onChangePrivacy: (state, isPrivate) =>
          @$('.im-private-query').toggle isPrivate

      onChangeURL: (state, url) =>
          @$('a.im-download').attr href: url

      onChangePermaquery: (state, permaquery) =>
          @$('.well.im-query-xml').text permaquery

      onChangePermalink: (state, permalink) =>
          $a = $('<a>').text(permalink).attr href: permalink
          @$('.im-perma-link-content').empty().append($a)

      onChangeDest:  =>
        destination = @state.get 'destination'
        [dest, action] = (intermine.messages.actions[x + destination] for x in ['Dest', ''])
        @$('.nav-tabs .im-export-destination .im-current').text dest
        @$('.btn-primary.im-download').text action

        @$('.im-export-destination-options > div').removeClass 'active'
        @$(".im-#{ destination.toLowerCase() }").addClass 'active'

      dontReallySubmitForm: (e) ->
          # Hack to fix bug in struts webapp
          e.preventDefault()
          e.stopPropagation()
          return false # seriously, don't

      keyPressOnLimit: (e) ->
        input = $(e.target)
        switch e.keyCode
          when 38 # UP
              input.val 1 + parseInt(input.val(), 10)
          when 40 # DOWN
              input.val parseInt(input.val(), 10) - 1
        input.change()

      changeStart: (e) ->
        if @checkStartAndEnd() # only if valid.
            @requestInfo.set start: parseInt(@$('.im-first-row').val(), 10) - 1 # Start is 0-based, display is 1-based.

      changeEnd: (e) ->
        if @checkStartAndEnd() # only if valid
            @requestInfo.set end: parseInt(@$('.im-last-row').val(), 10)

      DIGITS: /^\s*\d+\s*$/

      checkStartAndEnd: () ->
          start = @$('.im-first-row')
          end = @$('.im-last-row')
          valA = start.val()
          valB = end.val()
          ok = (@DIGITS.test(valA) and parseInt(valA, 10) >= 1) and (@DIGITS.test(valB) and parseInt(valB, 10) <= @count)
          if @DIGITS.test(valA) and @DIGITS.test(valB)
              ok = ok and (parseInt(valA, 10) <= parseInt(valB, 10))
          $('.im-row-selection').toggleClass('error', not ok)
          return ok

      ignore = (e) ->
          e.stopPropagation()
          e.preventDefault()


      getExportEndPoint: () ->
          format = @requestInfo.get 'format'
          suffix = if format in BIO_FORMATS then "/#{format.extension}" else ""
          return "#{ @service.root }query/results#{ suffix }"

      # Unnecessary? We could always use this if the url gets too big...
      # openWindowWithPost @getExportEndPoint(), "Export", @getExportParams()
      export: (e) ->
        dest = @state.get 'destination'
        if dest of intermine.export.external
          ignore e
          intermine.export.external[dest].export.call(@)
        else
          true # Do the default linky thing

      getExportQuery: (noIdCons = false) ->
          q = @query.clone()
          f = @requestInfo.get 'format'
          columns = switch f.extension
            when 'bed', 'gff3'
                featuresToPaths @seqFeatures
            when 'fasta'
                featuresToPaths @fastaFeatures
            else
                @exportedCols.filter(isntExcluded).map(toPath)

          q.select columns if columns?

          for path in @query.views when not q.isOuterJoined(path)
            node = q.getPathInfo(path).getParent()
            unless isImplicitlyConstrained q, node
              q.addConstraint path: node.append('id'), op: 'IS NOT NULL'

          newOrder = if f in BIO_FORMATS
            []
          else
            viewNodes = q.getViewNodes()
            _.filter q.sortOrder, ({path}) ->
              parent = q.getPathInfo(path).getParent()
              _.any viewNodes, (node) -> parent.equals node

          q.orderBy newOrder

          if noIdCons then getPermaQuery(q) else defer q

      # :: bool -> Promise<Object<String, String>>
      getExportParams: (noIdCons = false) ->
          params = @requestInfo.toJSON()
          params.token = @service.token
          params.format = @getFormatParam()

          # Clean up params we don't need to send
          for dummy in @dummyParams
            delete params[dummy]
          delete params.compress if params.compress is 'no'

          if params.format not in ['gff3', 'fasta']
            delete params.view

          if @requestInfo.get('columnHeaders') and params.format in ['tab', 'csv']
              params.columnheaders = "1"

          start = params.start = @requestInfo.get('start')
          end = @requestInfo.get 'end'
          if end isnt @count
              params.size = end - start

          @getExportQuery(noIdCons).then (q) ->
            params.query = q.toXML()
            return params

      getExportURI: (noIdCons = false) -> @getExportQuery(noIdCons).then (q) =>
          uri = q.getExportURI @getFormatParam()
          uri += @getExtraOptions()
          return uri

      getFormatParam: ->
        format = @requestInfo.get 'format'
        format.param or format.extension

      getExtraOptions: () ->
          ret = ""
          if @requestInfo.get 'columnHeaders'
              ret += "&columnheaders=1"
          unless @requestInfo.get 'allRows'
              start = @requestInfo.get 'start'
              end = @requestInfo.get 'end'
              ret += "&start=#{ start }"
              if end isnt @count
                  ret += "&size=#{ end - start }"
          ret

      toggleColSelection: (e) -> @requestInfo.set allCols: !@requestInfo.get('allCols'); false

      toggleRowSelection: (e) -> @requestInfo.set allRows: !@requestInfo.get('allRows'); false

      show: -> @$el.modal('show')

      stop: -> @$el.modal('hide')

      remove: () -> # Clean up thoroughly.
        for x in DELENDA
          obj = @[x]
          obj?.close?()
          obj?.destroy?()
          obj?.off()
          delete @[x]
        delete @query
        @$slider?.slider 'destroy'
        delete @$slider
        super()


      isSpreadsheet: ->
        {ColumnHeaders, SpreadsheetOptions} = intermine.messages.actions
        @$('.im-output-options').append  """
          <h2>#{ SpreadsheetOptions }</h2>
          <div>
            <label>
              <span class="span4">#{ ColumnHeaders }</span>
              <input type="checkbox" class="span8 im-column-headers">
            </label>
          </div>
        """
        @$('.im-column-headers').attr checked: !!@requestInfo.get 'columnHeaders'

      isBED: ->
        {BEDOptions, ChrPrefix} = intermine.messages.actions
        chrPref = $ """
          <h3>#{ BEDOptions }</h3>
          <div>
            <label>
              <span class="span4">#{ ChrPrefix }</span>
              <input type="checkbox" class="im-bed-chr-prefix span8">
            </label>
          </div>
        """
        chrPref.appendTo @$ '.im-output-options'
        chrPref.find('input').attr checked: !!@requestInfo.get('useChrPrefix')
        @addSeqFeatureSelector()

      isGFF3: ->
        @addSeqFeatureSelector()
        @$('.im-output-options').append """
          <h3>#{ intermine.messages.actions.Gff3Options}</h3>
        """
        @addExtraColumnsSelector()

      isFASTA: ->
        @addFastaFeatureSelector()
        @addFastaExtensionInput()
        @addExtraColumnsSelector()

      updateFormatOptions: () ->
        opts = @$('.im-output-options').empty()
        requestInfo = @requestInfo
        format = requestInfo.get 'format'

        if format in BIO_FORMATS
          @$('.im-col-options').hide()
          @$('.im-col-options-bio').show()
          @$('.tab-pane.im-export-rows').removeClass('active')
          @$('.nav-tabs .im-export-rows').text('All rows').parent().removeClass('active').addClass('disabled')
          @requestInfo.set start: 0, end: @count
        else
          @$('.im-col-options').show()
          @$('.im-col-options-bio').hide()
          @$('.nav-tabs .im-export-rows').parent().removeClass('disabled')

        if format.extension in ['tsv', 'csv']
          @isSpreadsheet()
        else
          @['is' + format.extension.toUpperCase()]?()

      addFastaExtensionInput: () ->
        {FastaOptions, FastaExtension} = intermine.messages.actions
        extOpt = $ """
          <h3>#{ FastaOptions }</h3>
          <div>
            <label>
              <span class="span4">#{ FastaExtension }</span>
              <input type="text"
                     placeholder="5kbp"
                     class="span8 im-fasta-extension">
            </label>
          </div>
        """
        extOpt.appendTo @$ '.im-output-options'
        extOpt.find('input').val @requestInfo.get 'extension'

      initExtraAttributes: ->
        coll = @extraAttributes.close()
        for path in @query.views when not @query.canHaveMultipleValues path
          coll.add path: @query.getPathInfo(path), included: false

      addExtraColumnsSelector: () ->
        @initExtraAttributes()

        row = new intermine.actions.ExportColumnOptions
          collection: @extraAttributes
          message: intermine.messages.actions.ExtraAttributes

        @$('.im-output-options').append row.render().$el

      initFastaFeatures: ->
        @fastaFeatures.close()
        included = true
        for node in @query.getViewNodes()
          if (node.isa 'SequenceFeature') or (node.isa 'Protein')
            @fastaFeatures.add path: node, included: included
            included = false

      addFastaFeatureSelector: () ->
        @initFastaFeatures()
        
        row = new intermine.actions.ExportColumnOptions
          collection: @fastaFeatures
          message: intermine.messages.actions.FastaFeatures

        row.isValidCount = (c) -> c is 1

        @$('.im-col-options-bio').html row.render().$el

      initSeqFeatures: ->
        @seqFeatures.close()
        for node in @query.getViewNodes() when node.isa 'SequenceFeature'
           @seqFeatures.add path: node, included: true

      addSeqFeatureSelector: ->
        @initSeqFeatures()

        row = new intermine.actions.ExportColumnOptions
          collection: @seqFeatures
          message: intermine.messages.actions.IncludedFeatures

        row.isValidCount = (c) -> c > 0

        @$('.im-col-options-bio').html row.render().$el


      initColumnOptions: ->
        nodes = ({node} for node in @query.getQueryNodes())
        @possibleColumns = new intermine.columns.models.PossibleColumns nodes,
          exported: @exportedCols

      initCols: () =>
        @$('ul.im-cols li').remove()

        cols = @$ '.im-exported-cols'
        @exportedCols.each (col) =>
          exported = new intermine.columns.views.ExportColumnHeader model: col
          exported.render().$el.appendTo cols

        cols.sortable
            items: 'li'
            axis: 'y'
            placeholder: 'im-resorting-placeholder im-exported-col'
            forcePlaceholderSize: true
            update: (e, ui) =>
              @$('.im-reset-cols').removeClass('disabled')
              @exportedCols.reset cols.find('li').map(-> $(@).data 'model' ).get()

        @initColumnOptions()

        maybes = @$ '.im-can-be-exported-cols'
        @maybeView?.remove()
        @maybeView = new intermine.columns.views.PossibleColumns
          collection: @possibleColumns
        maybes.append @maybeView.render().el

      warnOfOuterJoinedCollections: ->
        q = @query
        if _.any(q.joins, (s, p) => (s is 'OUTER') and q.canHaveMultipleValues(p))
          @$('.im-row-selection').append """
            <div class="alert alert-warning">
                <button class="close" data-dismiss="alert">×</button>
                <strong>NB</strong>
                #{ intermine.messages.actions.OuterJoinWarning }
            </div>
          """

      formatToEl = (format) -> """
        <div class="im-format-choice">
          <label class="radio">
            <input type="radio" class="im-format-#{ format.extension }"
                  name="im-export-format" value="#{ format.extension }">
            <i class="#{ intermine.icons[format.extension] }"></i>
            #{ format.name }
          </label>
        </div>
      """

      initFormats: () ->
        $formats = @$ '.tab-pane.im-export-format .im-export-formats'
        current = @requestInfo.get 'format'

        for format, i in EXPORT_FORMATS
          $btn = $ formatToEl format
          $btn[0].tabIndex = i
          $formats.append $btn

        @service.fetchModel().done (model) =>
          if intermine.utils.modelIsBio model
            viewNodeTypes = @query.getViewNodes().map (n) -> n.getType()
            isSuitableForThisQuery = anyNodeIsSuitable model, viewNodeTypes
            for format, i in BIO_FORMATS when isSuitableForThisQuery format.types
              $btn = $ formatToEl format
              $btn[0].tabIndex = i + EXPORT_FORMATS.length
              $formats.append $btn

        ext = @requestInfo.get('format').extension
        $formats.find('input').val [ ext ]


      render: () ->

        @$el.append intermine.snippets.actions.DownloadDialogue()

        @initFormats()
        @initCols()
        @makeSlider()
        @updateFormatOptions()
        @warnOfOuterJoinedCollections()
        @addExternalExports()

        @state.trigger 'change:destination'
        @requestInfo.trigger 'change'
        @requestInfo.trigger 'change:format'

        this

      addExternalExports: ->
        $options = @$ '.im-export-destination-options'
        $navs = @$ '.im-export-destinations.nav'
        for name, enabled of intermine.options.ExternalExportDestinations when enabled
          action = "SendTo" + name
          $navs.append """
            <li>
              <a data-destination="#{ name }">
                #{ intermine.messages.actions[action] }
              </a>
            </li>
          """
          $options.append intermine.export.snippets[name]?(@requestInfo.toJSON())


      makeSlider: () ->
        # Unset any previous sliders.
        @$slider?.slider 'destroy'
        @$slider = null
        @query.count (c) =>
          @count = c
          @requestInfo.set end: c
          @$slider = @$('.im-row-range-slider').slider
            range: true,
            min: 0,
            max: c - 1,
            values: [0, c - 1],
            step: 1,
            slide: (e, ui) => @requestInfo.set start: ui.values[0], end: ui.values[1] + 1

  scope "intermine.query.export", {ExportDialogue}
