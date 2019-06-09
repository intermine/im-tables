$ = require 'jquery'
_ = require 'underscore'
{Promise} = require 'es6-promise'

Options = require '../options'
loadResource = require './load-resource'

__GOOGLE = null # close over this variable.
LIB = 'Destination.Drive.Library'
BOUNDARY = "-------314159265358979323846"
DELIMITER = "\r\n--" + BOUNDARY + "\r\n"
CLOSE_DELIM = "\r\n--" + BOUNDARY + "--"
VERSION = 'v2'
SCOPE = "https://www.googleapis.com/auth/drive.file"
ERR = 'No configuration available for Google Drive'
METADATA_CT = "Content-Type: application/json\r\n\r\n"
FILE_CT = "Content-Type: text/tab-separated-values\r\n\r\n"
REQ_CT = "multipart/mixed; boundary=\"" + BOUNDARY + "\""
DRIVE_PATH = "/upload/drive/v2/files"
DRIVE_METHOD = 'POST'
REQ_PARAMS =
  path: DRIVE_PATH
  method: DRIVE_METHOD
  params:
    uploadType: 'multipart'
  headers:
    'Content-Type': REQ_CT

# Reuse or assign to __GOOGLE, which is a Promise
withExporter = -> __GOOGLE ?= loadResource(LIB, 'gapi').then (api) -> new GoogleExporter api

module.exports = sendToGoogleDrive = (uri, filename, onProgress) -> withExporter().then (e) ->
  onProgress 1 # 1 means indeterminate.
  return e.upload uri, filename

class MetaData

  mimetype: 'text/plain'

  constructor: (@title) ->

  toString: -> JSON.stringify {@title, @mimetype}

class GoogleExporter

  constructor: (@gapi) ->
    throw new Error('No api') unless @gapi
    throw new Error ERR unless Options.get 'auth.drive'
    console.log @gapi

  # Wrapper around gapi.authorize to return a promise
  authorize: -> new Promise (resolve, reject) =>
    gapi = @gapi
    timeout = null
    opts =
      client_id: Options.get('auth.drive')
      scope: SCOPE
      immediate: false # Immediate means if we expect there to be no user interaction
    # Because of how google loads itself, we may need to wait for it to be initialized, hence
    # the elaborate asynch loop.
    nextStep = ->
      gapi.auth.authorize opts, (auth) ->
        return reject new Error 'Not authorized' unless auth?
        return reject new Error auth.error if auth.error
        resolve()
    abort = ->
      clearTimeout timeout
      reject new Error 'timed out' # no-op if already resolved.
    checkOrWait = ->
      clearTimeout timeout
      if gapi.auth?.authorize # Cool, we can proceeed.
        nextStep()
      else # not ready yet - come back later...
        timeout = setTimeout checkOrWait, 50
    checkOrWait()
    # Wait up to 5 seconds for gapi to get its act together
    setTimeout abort, 5000 
    return

  # Wrapper around gapi.client.load to return a promise
  loadClient: -> new Promise (resolve, reject) => @gapi.client.load "drive", VERSION, resolve

  # Construct the request body from the metadata and the data.
  makeRequestBody: (metadata, data) ->
    DELIMITER + METADATA_CT + String(metadata) + DELIMITER + FILE_CT + data + CLOSE_DELIM

  # Construct a gapi request object, which is a Promise, thus ensuring we wait for success.
  # see: https://developers.google.com/api-client-library/javascript/reference/referencedocs#gapiclientRequest
  makeRequest: (body) -> @gapi.client.request _.extend {body}, REQ_PARAMS

  # (string, string) -> Promise<string>
  # There is no way to report progress for uploads to Google Drive.
  upload: (uri, filename) ->
    @authorize().then => @loadClient()
                .then -> Promise.resolve $.get uri
                .then (data) => @makeRequestBody new MetaData(filename), data
                .then (body) => @makeRequest body
                .then (resp) -> resp.result.alternateLink
