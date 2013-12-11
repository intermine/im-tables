define 'actions/code-gen', using 'perma-query', 'html/code-gen', (getPermaQuery, HTML) ->

  CODE_GEN_LANGS = [
      {name: "Perl", extension: "pl"},
      {name: "Python", extension: "py"},
      {name: "Ruby", extension: "rb"},
      {name: "Java", extension: "java"},
      {name: "JavaScript", extension: "js"}
      {name: "XML", extension: "xml"}
  ]
    
  # Rather naive (but generally effective) method of
  # prettifying the otherwise compressed XML.
  indent = (xml) ->
    lines = xml.split /></
    indentLevel = 1
    buffer = []
    for line in lines
      unless />$/.test line
        line = line + '>'
      unless /^</.test line
        line = '<' + line

      isClosing = /^<\/\w+\s*>/.test(line)
      isOneLiner = /\/>$/.test(line) or (not isClosing and /<\/\w+>$/.test(line))
      isOpening = not (isOneLiner or isClosing)

      indentLevel-- if isClosing

      buffer.push new Array(indentLevel).join('  ') + line
      
      indentLevel++ if isOpening

    return buffer.join("\n")

  {get, invoke} = intermine.funcutils
  defer = (x) -> jQuery.Deferred -> @resolve x
  alreadyDone = defer true
  alreadyRejected = jQuery.Deferred -> @reject 'not available'

  class CodeGenerator extends Backbone.View
    tagName: "li"
    className: "im-code-gen"

    html: HTML {langs: CODE_GEN_LANGS}

    initialize: (@states) ->
      @model = new Backbone.Model
      @model.on 'set:lang', @displayLang

    render: =>
      @$el.append @html
      @$('.modal').hide() # I have no idea why this is needed.
      this

    events:
      'click .im-show-comments': 'showComments'
      'click .dropdown-menu a': 'setLang'
      'click .btn-action': 'doMainAction'

    showComments: (e) =>
      if $(e.target).is '.active'
        @compact()
      else
        @expand()

    setLang: (e) ->
      $t = $ e.target
      @model.set {lang: $t.data('lang') or @model.get('lang')}, {silent: true}
      @model.trigger 'set:lang'

    canSaveFromMemory = ->
      if not Blob?
        alreadyRejected
      if saveAs?
        alreadyDone
      else
        intermine.cdn.load 'filesaver'

    displayLang: =>
      $m    = @$ '.modal'
      lang  = @model.get('lang')

      query = @states.currentQuery
      pq = getPermaQuery query

      ext   = if lang is 'js'  then 'html' else lang
      href  = if lang is 'xml' then ''    else query.getCodeURI lang
      ready = if prettyPrintOne? then alreadyDone else intermine.cdn.load 'prettify'
      code  = if lang is 'xml'
        pq.then(invoke 'toXML').then(indent)
      else
        pq.then(invoke 'fetchCode', lang)

      @$('a .im-code-lang').text lang
      @$('.modal h3 .im-code-lang').text lang

      saveBtn = @$('.modal .btn-save').removeClass('disabled').unbind('click').attr href: null
      if lang is 'xml'
        saveBtn.addClass 'disabled'
        jQuery.when(code, canSaveFromMemory()).done (xml) ->
          saveBtn.removeClass('disabled').click ->
            blob = new Blob [xml], type: 'application/xml;charset=utf8'
            saveAs blob, 'query.xml'
      else
        pq.then(invoke 'getCodeURI', lang).then (href) -> saveBtn.attr {href}

      @states.on 'error', console.error.bind(console)

      jQuery.when(code, ready).fail((e) => @states.trigger 'error', e).then (code) ->
        formatted = prettyPrintOne(_.escape(code), ext)
        $m.find('pre').html formatted
        $m.modal 'show'

    doMainAction: (e) =>
      if @model.has('lang') then @displayLang() else $(e.target).next().dropdown 'toggle'

    compact: =>
      $m = @$ '.modal'
      $m.find('span.com').closest('li').slideUp()
      $m.find('.linenums li').filter(-> $(@).text().replace(/\s+/g, "") is "").slideUp()

    expand: =>
      $m = @$ '.modal'
      $m.find('linenums li').slideDown()
