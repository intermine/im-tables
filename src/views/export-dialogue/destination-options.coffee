_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'
Options = require '../../options'
Formats = require '../../models/export-formats'

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

  events: ->
    evts =
      '.change .im-param-name input': 'setName'

    types = @model.get 'has'
    for fmt in Formats.getFormats types
      evts["click .im-fmt-#{ fmt.id }"] = @setFormat.bind @, fmt
    return evts

  setName: (e) -> @model.set name: e.target.value

  setFormat: (format) -> @model.set format: format.id

