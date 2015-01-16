_ = require 'underscore'

# Base class
Modal = require './modal'

# Base model
CoreModel = require '../core-model'
# Text strings
Messages = require '../messages'
# Configuration
Options = require '../options'
# Templating
Templates = require '../templates'
# This class uses the code-gen message bundle.
require '../messages/code-gen'
# We use this xml indenter
indentXml = require '../utils/indent-xml'
# We use this string compacter.
stripExtraneousWhiteSpace = require '../utils/strip-extra-whitespace'
# We need access to a cdn resource - google's prettify
withResource = require '../utils/with-cdn-resource'

# Comment finding regexen
OCTOTHORPE_COMMENTS = /\s*#.*$/gm
C_STYLE_COMMENTS = /(\s*\/\/.*$|\/\*(\*(?!\/)|[^*])*\*\/)/gm

withPrettyPrintOne = _.partial withResource, 'prettify', 'prettyPrintOne'

# The data model has three bits - the language, and a couple of presentation
# options.
class CodeGenModel extends CoreModel

  defaults: ->
    lang: Options.get('CodeGen.Default') # The code-gen lang. See Options.CodeGen.Langs
    showBoilerPlate: false # Should we show language boilerplate.
    highlightSyntax: true  # Should we do syntax highlighting

module.exports = class CodeGenDialogue extends Modal

  # Connect this view with its model.
  Model: CodeGenModel

  # We need a query, and we need to start generating our code.
  initialize: ({@query}) ->
    super
    @generateCode()

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
    'change:lang': @onChangeLang
    'change:showBoilerPlate': @reRenderBody
    'change:highlightSyntax': @reRenderBody

  # Show the code if it changes.
  stateEvents: -> 'change:generatedCode': @reRenderBody

  # The DOM events - setting the attributes of the model.
  events: ->
    'click .dropdown-menu.im-code-gen-langs li': 'chooseLang'
    'change .im-show-boilerplate': 'toggleShowBoilerPlate'
    'change .im-highlight-syntax': 'toggleHighlightSyntax'

  # Get a regular expression that will strip comments.
  getBoilerPlateRegex: ->
    return if @model.get 'showBoilerPlate'
    switch @model.get 'lang'
      when 'pl', 'py', 'rb' then OCTOTHORPE_COMMENTS
      when 'java' then C_STYLE_COMMENTS
      else null

  onChangeLang: ->
    lang = @model.get 'lang'
    @$('.im-current-lang').text Messages.getText 'codegen.Lang', {lang}
    @$('.modal-title').text @title()
    @generateCode()

  generateCode: ->
    lang = @model.get 'lang'
    switch lang
      when 'xml' then @state.set generatedCode: indentXml @query.toXML()
      else @query.fetchCode(lang).then (code) => @state.set generatedCode: code

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
    @highlightCode()

  highlightCode: -> if @model.get 'highlightSyntax'
    lang = @model.get 'lang'
    pre = @$ '.im-generated-code'
    code = @getCode()
    return unless code?
    withPrettyPrintOne (prettyPrintOne) -> pre.html prettyPrintOne _.escape code

  getData: -> _.extend super, options: Options.get('CodeGen'), generatedCode: @getCode()

  getCode: ->
    code = @state.get 'generatedCode'
    regex = @getBoilerPlateRegex()
    return code unless regex
    stripExtraneousWhiteSpace code?.replace regex, ''

  # Information flow from DOM -> Model

  toggleShowBoilerPlate: -> @model.toggle 'showBoilerPlate'

  toggleHighlightSyntax: -> @model.toggle 'highlightSyntax'

  chooseLang: (e) ->
    lang = @$(e.target).closest('li').data 'lang'
    @model.set lang: lang

