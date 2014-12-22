_ = require 'underscore'

Modal = require './modal'
ConstraintAdder = require './constraint-adder'
Messages = require '../messages'
Templates = require '../templates'

Menu = require './export-dialogue/tab-menu'
FormatControls = require './export-dialogue/format-controls'

# Very simple dialogue that just wraps a ConstraintAdder
module.exports = class ExportDialogue extends Modal

  className: -> 'im-export-dialogue ' + super

  initialize: ({@query}) ->
    super
    @state.set tab: 'format', dest: 'FAKE DATA'
    @listenTo @state, 'change:tab', @renderMain

  title: -> Messages.getText 'ExportTitle', {name: @query.name}

  primaryAction: -> Messages.getText 'ExportButton'

  body: Templates.template 'export_dialogue'

  getMain: ->
    switch @state.get('tab')
      when 'format' then FormatControls
      else FormatControls

  renderMain: ->
    Main = @getMain()
    @renderChild 'main', (new Main {@model, @query}), @$ 'div.main'

  postRender: ->
    @renderChild 'menu', (new Menu {model: @state}), @$ 'nav.menu'
    @renderMain()
    super
