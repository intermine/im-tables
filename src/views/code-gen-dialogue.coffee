_ = require 'underscore'

Modal = require './modal'

CoreModel = require '../core-model'
Messages = require '../messages'
Options = require '../options'
Templates = require '../templates'

require '../messages/code-gen'

class CodeGenModel extends CoreModel

  defaults: ->
    lang: Options.get('CodeGen.Default')

module.exports = class CodeGenDialogue extends Modal

  Model: CodeGenModel

  initialize: ({@query}) ->
    super
    @generateCode()

  modelEvents: -> 'change:lang': @onChangeLang

  stateEvents: -> 'change:generatedCode': @reRenderBody

  modalSize: -> 'lg'

  onChangeLang: ->
    lang = @model.get 'lang'
    @$('.im-current-lang').text Messages.getText 'codegen.Lang', {lang}
    @$('.modal-title').text @title()
    @generateCode()

  generateCode: ->
    lang = @model.get 'lang'
    switch lang
      when 'xml' then @state.set generatedCode: @query.toXML()
      else @query.fetchCode(lang).then (code) => @state.set generatedCode: code

  title: -> Messages.getText 'codegen.DialogueTitle', query: @query, lang: @model.get('lang')

  primaryIcon: -> 'Download'

  body: Templates.template 'code_gen_body'

  getData: -> _.extend super, options: Options.get('CodeGen')

  primaryAction: -> Messages.getText 'codegen.PrimaryAction'

  events: ->
    'click .dropdown-menu.im-code-gen-langs li': 'chooseLang'

  chooseLang: (e) ->
    lang = @$(e.target).closest('li').data 'lang'
    @model.set lang: lang

