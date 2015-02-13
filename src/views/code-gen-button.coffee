_ = require 'underscore'

CoreView = require '../core-view'

# Text strings
Messages = require '../messages'
# Configuration
Options = require '../options'
# Templating
Templates = require '../templates'
# The model for this class.
CodeGenModel = require '../models/code-gen'
Dialogue = require './code-gen-dialogue'

# This class uses the code-gen message bundle.
require '../messages/code-gen'

module.exports = class CodeGenButton extends CoreView

  parameters: ['query']

  # Connect this view with its model.
  Model: CodeGenModel

  # The template which renders this view.
  template: Templates.template 'code-gen-button'

  # The data that the template renders.
  getData: -> _.extend super, options: Options.get('CodeGen')

  modelEvents: ->
    'change:lang': @onChangeLang

  events: ->
    'click .dropdown-menu.im-code-gen-langs li': 'chooseLang'
    'click .im-show-code-gen-dialogue': 'showDialogue'

  chooseLang: (e) ->
    lang = @$(e.target).closest('li').data 'lang'
    @model.set lang: lang

  onChangeLang: ->
    lang = @model.get 'lang'
    @$('.im-current-lang').text Messages.getText 'codegen.Lang', {lang}

  showDialogue: ->
    dialogue = new Dialogue {@query, @model}
    @renderChild 'dialogue', dialogue
    # Returns a promise, but in this case we don't care about it.
    dialogue.show()
