fs = require 'fs'
_ = require 'underscore'

Options = require '../options'
Messages = require '../messages'
Icons = require '../icons'

mustacheSettings = require '../templates/mustache-settings'
html = fs.readFileSync __dirname + '/../templates/too-many-suggestions.html', 'utf8'
template = _.template html, mustacheSettings

module.exports = class SuggestionSource

  tooMany: '<span></span>'

  constructor: (@suggestions, @total) ->
    maxSuggestions = Options.get('MaxSuggestions')
    if @total > maxSuggestions
      @tooMany = template icons: Icons, messages: Messages, extra: total - maxSuggestions

  suggest: (term, cb) =>
    if not term? or term is ''
      return cb(s for s in @suggestions.slice(0, 10))
    parts = (term?.toLowerCase()?.split(' ') ? [])
    matches = ({item}) ->
      item ?= ''
      _.all parts, (p) -> item.toLowerCase().indexOf(p) >= 0
    cb(s for s in @suggestions when matches s)

