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

checkRequest = (req) ->
  throw new Error(req.statusText) unless req.status is 200
  return req.result?.alternateLink

# Reuse or assign to __GOOGLE, which is a Promise
withExporter = -> __GOOGLE ?= loadResource(LIB, 'gapi').then (api) -> new GoogleExporter api

module.exports = sendToGoogleDrive = (uri, filename) -> withExporter().then (exporter) ->
  exporter.upload uri, filename

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
    opts =
      client_id: Options.get('auth.drive')
      scope: SCOPE
      immediate: false # Immediate means if we expect there to be no user interaction
    nextStep = =>
      @gapi.auth.authorize opts, (auth) ->
        return reject new Error 'Not authorized' unless auth?
        return reject new Error auth.error if auth.error
        resolve()
    # Because of how google loads itself, we may need to wait for it to be initialized.
    if @gapi.auth then nextStep() else setTimeout nextStep, 10

  # Wrapper around gapi.client.load to return a promise
  loadClient: -> new Promise (resolve, reject) => @gapi.client.load "drive", VERSION, resolve

  # Construct the request body from the metadata and the data.
  makeRequestBody: (metadata, data) ->
    DELIMITER + METADATA_CT + String(metadata) + DELIMITER + FILE_CT + data + CLOSE_DELIM

  # Construct a gapi request object.
  makeRequest: (body) -> @gapi.client.request _.extend {body}, REQ_PARAMS

  upload: (uri, filename) ->
    @authorize().then => @loadClient()
                .then -> Promise.resolve $.get uri
                .then (data) => @makeRequestBody new MetaData(filename), data
                .then (body) => @makeRequest body
                .then checkRequest
