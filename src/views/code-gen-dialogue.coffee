_ = require 'underscore'

Modal = require './modal'

CoreModel = require '../core-model'
Messages = require '../messages'
Options = require '../options'
Templates = require '../templates'

require '../messages/code-gen'

indentXml = require '../utils/indent-xml'

class CodeGenModel extends CoreModel

  defaults: ->
    lang: Options.get('CodeGen.Default')
    showBoilerPlate: false
    highlightSyntax: false

OCTOTHORPE_COMMENTS = /\s*#.*$/gm
C_STYLE_COMMENTS = /(\s*\/\/.*$|\/\*(\*(?!\/)|[^*])*\*\/)/gm

stripExtraneousWhiteSpace = (str) ->
  return unless str?
  str = str.replace /\n\s*\n/g, '\n\n'
  str.replace /(^\s*|\s*$)/g, ''

module.exports = class CodeGenDialogue extends Modal

  Model: CodeGenModel

  initialize: ({@query}) ->
    super
    @generateCode()

  modelEvents: ->
    'change:lang': @onChangeLang
    'change:showBoilerPlate': @reRenderBody

  stateEvents: -> 'change:generatedCode': @reRenderBody

  modalSize: -> 'lg'

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

  title: -> Messages.getText 'codegen.DialogueTitle', query: @query, lang: @model.get('lang')

  primaryIcon: -> 'Download'

  body: Templates.template 'code_gen_body'

  # This could potentially go into Modal, but it would need more stuff
  # to make it generic (dealing with children, etc). Not worth it for
  # such a simple method.
  reRenderBody: -> if @rendered
    # Replace the body with the current state of the body.
    @$('.modal-body').html @body @getData()
    # Trigger any DOM modifications, also re-renders the footer.
    @trigger 'rendered', @rendered

  getData: -> _.extend super, options: Options.get('CodeGen'), generatedCode: @getCode()

  getCode: ->
    code = @state.get 'generatedCode'
    regex = @getBoilerPlateRegex()
    return code unless regex
    stripExtraneousWhiteSpace code?.replace regex, ''

  primaryAction: -> Messages.getText 'codegen.PrimaryAction'

  events: ->
    'click .dropdown-menu.im-code-gen-langs li': 'chooseLang'
    'change .im-show-boilerplate': 'toggleShowBoilerPlate'
    'change .im-highlight-syntax': 'toggleHighlightSyntax'
    
  toggleShowBoilerPlate: -> @model.toggle 'showBoilerPlate'
  toggleHighlightSyntax: -> @model.toggle 'highlightSyntax'

  chooseLang: (e) ->
    lang = @$(e.target).closest('li').data 'lang'
    @model.set lang: lang

