_ = require 'underscore'
{Promise} = require 'es6-promise'

Options = require '../options'
Messages = require '../messages'

# Utils that promise to return some metadata.
getOrganisms = require './get-organisms'
getBranding = require './branding'
getResultClass = require './get-result-class'

openWindowWithPost = require './open-window-with-post'
parseUrl = require './parse-url'

# Find out which Galaxy to send stuff to, work out all the parameters, and send it off
# in a hidden post form.
module.exports = send = (url, filename, onProgress) ->
  Galaxy = Options.get 'Destination.Galaxy'
  uri = (Galaxy.Current ? Galaxy.Main)
  uri += '/tool_runner' unless /tool_runner$/.test uri

  gettingBranding = getBranding @query.service
  gettingResultClass = getResultClass @query
  gettingOrganisms = getOrganisms @query

  Promise.all [gettingResultClass, gettingOrganisms, gettingBranding]
         .then getParameters url, @query, @model.format.ext
         .then _.partial openWindowWithPost, uri, 'Upload'

# Turn all the info we have into a single set of Galaxy compatible parameters.
getParameters = (url, query, ext) -> ([cls, orgs, branding]) ->
  {URL, params} = parseUrl url # one canonical source of truth is best.
  lists = (c.value for c in query.constraints when c.op is 'IN')
  data_type = if ext is 'tsv' then 'tabular' else ext
  currentLocation = window.location.toString().replace /\?.*$/, '' # strip query-string
  tool_id = Options.get 'Destination.Galaxy.Tool'
  name = Messages.getText 'export.galaxy.name', {cls, orgs, branding}
  info = Messages.getText 'export.galaxy.info', {query, lists, orgs, currentLocation}
  organism = orgs.join(', ') if orgs?

  _.extend params, {tool_id, URL, name, info, data_type, organism, URL_method: 'post'}

# Set the user's preferred galaxy, if they want it to be stored.
send.after = ->
  Galaxy = Options.get 'Destination.Galaxy'
  if Galaxy.Current and Galaxy.Save
    @query.service.whoami().then (user) ->
      if user.preferences['galaxy-url'] isnt Galaxy.Current
        user.setPreference 'galaxy-url', Galaxy.Current
  else
    Promise.resolve null

