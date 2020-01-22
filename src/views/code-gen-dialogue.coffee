_ = require 'underscore'
{Promise} = require 'es6-promise'

# Base class
Modal = require './modal'

# Text strings
Messages = require '../messages'
# Configuration
Options = require '../options'
# Templating
Templates = require '../templates'
# The model for this class.
CodeGenModel = require '../models/code-gen'
# The checkbox sub-component.
Checkbox = require '../core/checkbox'
# This class uses the code-gen message bundle.
require '../messages/code-gen'
# We use this xml indenter
indentXml = require '../utils/indent-xml'
# We use this string compacter.
stripExtraneousWhiteSpace = require '../utils/strip-extra-whitespace'
# We need access to a cdn resource - google's prettify
withResource = require '../utils/with-cdn-resource'

# Comment finding regexen
OCTOTHORPE_COMMENTS = /\s*#[^!].*$/gm
C_STYLE_COMMENTS = /\/\*(\*(?!\/)|[^*])*\*\//gm # just strip blocks.
XML_MIMETYPE = 'application/xml;charset=utf8'
JS_MIMETYPE = 'text/javascript;charset=utf8'
HTML_MIMETYPE = 'text/html;charset=utf8'
CANNOT_SAVE = {level: 'Info', key: 'codegen.CannotExportXML'}
MIMETYPES =
  js: JS_MIMETYPE
  xml: XML_MIMETYPE
  html: HTML_MIMETYPE

withPrettyPrintOne = _.partial withResource, 'prettify', 'prettyPrintOne'

withFileSaver = _.partial withResource, 'filesaver', 'saveAs'

alreadyRejected = Promise.reject 'Requirements not met'

stripEmptyValues = (q) ->
  _.object( [k, v] for k, v of q when v and v.length isnt 0 )

canSaveFromMemory = ->
  if not 'Blob' in global
    alreadyRejected
  else
    withFileSaver _.identity

module.exports = class CodeGenDialogue extends Modal

  # Connect this view with its model.
  Model: CodeGenModel

  parameters: ['query']

  optionalParameters: ['page']

  page:
    start: 0
    size: (Options.get 'DefaultPageSize')

  # We need a query, and we need to start generating our code.
  initialize: ->
    super
    @generateCode()
    @setExportLink()

  # The static descriptive stuff.

  modalSize: -> 'lg'

  title: -> Messages.getText 'codegen.DialogueTitle', query: @query, lang: @model.get('lang')

  primaryIcon: -> 'Download'

  primaryAction: -> Messages.getText 'codegen.PrimaryAction'

  body: Templates.template 'code_gen_body'

  # Conditions which must be true on instantiation

  invariants: ->
    hasQuery: "No query"

  hasQuery: -> @query?

  # Recalulate the code if the lang changes, otherwise just re-present it.
  modelEvents: ->
    'change': @onChangeLang
    'change:showBoilerPlate': @reRenderBody
    'change:highlightSyntax': @reRenderBody

  # Show the code if it changes.
  stateEvents: -> 'change:generatedCode': @reRenderBody

  # The DOM events - setting the attributes of the model.
  events: -> _.extend super,
    'click .dropdown-menu.im-code-gen-langs li': 'chooseLang'

  # Get a regular expression that will strip comments.
  getBoilerPlateRegex: ->
    return if @model.get 'showBoilerPlate'
    switch @model.get 'lang'
      when 'pl', 'py', 'rb' then OCTOTHORPE_COMMENTS
      when 'java', 'js' then C_STYLE_COMMENTS
      else null

  act: -> # only called for XML data, and only in supported browsers.
    lang = @model.get('lang')
    lang = 'html' if lang is 'js' and @model.get('extrajs')
    blob = new Blob [@state.get('generatedCode')], type: MIMETYPES[lang]
    filename = "#{ @query.name ? 'name' }.#{ lang }"
    withFileSaver (saveAs) => saveAs blob, filename

  onChangeLang: ->
    lang = @model.get 'lang'
    @$('.im-current-lang').text Messages.getText 'codegen.Lang', {lang}
    @$('.modal-title').text @title()
    if lang in ['js', 'xml']
      canSaveFromMemory().then => @state.unset 'error'
                         .then null, => @state.set error: CANNOT_SAVE
    else
      @state.unset 'error'
    @generateCode()
    @setExportLink()

  generateCode: ->
    lang = @model.get 'lang'
    switch lang
      when 'xml' then @state.set generatedCode: @generateXML()
      when 'js'  then @state.set generatedCode: @generateJS()
      else
        # TODO
        # Safari 8 is caching imjs.fetchCode() even when options
        # change. So, for example, prior results fetchCode('py') are
        # smothering results for fetchCode('java'). Use our own cache for now.
        @getCodeFromCache lang

  getCodeFromCache: (lang) ->
    if !@cache? then @cache = {}
    if @cache?[lang]?
      @state.set generatedCode: @cache[lang]
    else
      opts =
        query: @query.toXML()
        lang: lang
        date: Date.now()
      # Bust the cache
      @query.service.post('query/code?cachebuster=' + Date.now(), opts).then (res) =>
        @cache[lang] = res.code
        @state.set generatedCode: res.code

  generateXML: ->
    indentXml @query.toXML()

  generateJS: ->
    t = Templates.template 'code-gen-js'
    query = stripEmptyValues @query.toJSON()
    cdnBase = Options.get('CDN.server') + Options.get(['CDN', 'imtables'])
    data =
      service: @query.service
      query: query
      page: @page
      asHTML: @model.get('extrajs')
      imtablesJS: cdnBase + 'imtables.js'
      imtablesCSS: cdnBase + 'main.sandboxed.css'
    t data

  # If the exportLink is null, then CodeGenDialogue#act will be called.
  setExportLink: ->
    lang = @model.get 'lang'
    switch lang
      when 'xml', 'js' then @state.set exportLink: null
      else @state.set exportLink: @query.getCodeURI lang

  # This could potentially go into Modal, but it would need more stuff
  # to make it generic (dealing with children, etc). Not worth it for
  # such a simple method.
  reRenderBody: -> if @rendered
    # Replace the body with the current state of the body.
    @$('.modal-body').html @body @getData()
    # Trigger any DOM modifications, also re-renders the footer.
    @trigger 'rendered', @rendered

  postRender: ->
    super
    @addCheckboxes()
    @highlightCode()
    @setMaxHeight()

  setMaxHeight: ->
    maxHeight = Math.max 250, (@$el.closest('.modal').height() - 200)
    @$('.im-generated-code').css 'max-height': maxHeight

  addCheckboxes: ->
    @renderChildAt '.im-show-boilerplate', new Checkbox
      model: @model
      attr: 'showBoilerPlate'
      label: 'codegen.ShowBoilerPlate'
    @renderChildAt '.im-highlight-syntax', new Checkbox
      model: @model
      attr: 'highlightSyntax'
      label: 'codegen.HighlightSyntax'
    if (opt = Options.get(['CodeGen', 'Extra', @model.get('lang')]))
      @renderChildAt '.im-extra-options', new Checkbox
        model: @model
        attr: ('extra' + @model.get('lang'))
        label: opt

  highlightCode: -> if @model.get 'highlightSyntax'
    lang = @model.get 'lang'
    pre = @$ '.im-generated-code'
    code = @getCode()
    return unless code?
    withPrettyPrintOne (prettyPrintOne) -> pre.html prettyPrintOne _.escape code

  getData: -> _.extend super,
    options: Options.get('CodeGen')
    generatedCode: @getCode()

  getCode: ->
    code = @state.get 'generatedCode'
    regex = @getBoilerPlateRegex()
    return code unless regex
    stripExtraneousWhiteSpace code?.replace regex, ''

  # Information flow from DOM -> Model

  toggleShowBoilerPlate: -> @model.toggle 'showBoilerPlate'

  toggleHighlightSyntax: -> @model.toggle 'highlightSyntax'

  chooseLang: (e) ->
    e.stopPropagation()
    lang = @$(e.target).closest('li').data 'lang'
    @model.set lang: lang
