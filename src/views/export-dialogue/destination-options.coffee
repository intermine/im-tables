_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'
Options = require '../../options'
Formats = require '../../models/export-formats'

# TODO: allow other destinations to register their options.
class DestinationSubOptions extends CoreView

  RERENDER_EVENT: 'change:dest'

  initialize: ->
    super
    @Galaxy = Options.get('Destination.Galaxy')
    unless @model.has('galaxyUri')
      @model.set galaxyUri: (@Galaxy.Current ? @Galaxy.Main)
    unless @model.has('saveGalaxy')
      @model.set saveGalaxy: false

    # Make sure this property is saved to the Options.
    @listenTo @model, 'change:galaxyUri', =>
      Options.set 'Destination.Galaxy.Current', @model.get 'galaxyUri'

  getData: -> _.extend super, Galaxy: @Galaxy

  # Dispatches to the template to use.
  getTemplate: -> switch @model.get 'dest'
    when 'Galaxy' then @galaxyTemplate
    else (-> '')

  # These are stored at class definition time to avoid reparsing the templates.
  galaxyTemplate: Templates.template 'export_destination_galaxy_options'

  template: (data) -> @getTemplate()(data)

  events: ->
    'change .im-galaxy-uri-param': 'setGalaxyUri'
    'change .im-save-galaxy input': 'toggleSaveGalaxy'

  setGalaxyUri: ({target}) -> @model.set galaxyUri: target.value

  toggleSaveGalaxy: -> @model.toggle 'saveGalaxy'

class RadioButtons extends CoreView

  RERENDER_EVENT: 'change:dest'

  destinations: -> (d for d in Options.get('Destinations') \
                            when Options.get(['Destination', d, 'Enabled']))

  getData: -> _.extend {destinations: @destinations()}, super

  template: Templates.template 'export_destination_radios'

  setDest: (d) -> => @model.set dest: d

  events: -> _.object( ["click .im-dest-#{ d }", @setDest d] \
                                           for d in @destinations())

module.exports = class DestinationOptions extends CoreView

  RERENDER_EVENT: 'change:format'

  getData: ->
    types = @model.get 'has'
    formats = Formats.getFormats types
    _.extend {formats}, super

  template: Templates.template 'export_destination_options'

  postRender: ->
    @renderChildAt '.im-param-dest', (new RadioButtons model: @state)
    @renderChildAt '.im-dest-opts', (new DestinationSubOptions model: @state)

  events: ->
    evts =
      '.change .im-param-name input': 'setName'

    types = @model.get 'has'
    for fmt in Formats.getFormats types
      evts["click .im-fmt-#{ fmt.id }"] = @setFormat.bind @, fmt
    return evts

  setName: (e) -> @model.set filename: e.target.value

  setFormat: (format) -> @model.set {format}

