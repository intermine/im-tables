let sendToGoogleDrive;
const $ = require('jquery');
const _ = require('underscore');
const {Promise} = require('es6-promise');

const Options = require('../options');
const loadResource = require('./load-resource');

let __GOOGLE = null; // close over this variable.
const LIB = 'Destination.Drive.Library';
const BOUNDARY = "-------314159265358979323846";
const DELIMITER = `\r\n--${BOUNDARY}\r\n`;
const CLOSE_DELIM = `\r\n--${BOUNDARY}--`;
const VERSION = 'v2';
const SCOPE = "https://www.googleapis.com/auth/drive.file";
const ERR = 'No configuration available for Google Drive';
const METADATA_CT = "Content-Type: application/json\r\n\r\n";
const FILE_CT = "Content-Type: text/tab-separated-values\r\n\r\n";
const REQ_CT = `multipart/mixed; boundary="${BOUNDARY}"`;
const DRIVE_PATH = "/upload/drive/v2/files";
const DRIVE_METHOD = 'POST';
const REQ_PARAMS = {
  path: DRIVE_PATH,
  method: DRIVE_METHOD,
  params: {
    uploadType: 'multipart'
  },
  headers: {
    'Content-Type': REQ_CT
  }
};

// Reuse or assign to __GOOGLE, which is a Promise
const withExporter = () => __GOOGLE != null ? __GOOGLE : (__GOOGLE = loadResource(LIB, 'gapi').then(api => new GoogleExporter(api)));

module.exports = (sendToGoogleDrive = (uri, filename, onProgress) => withExporter().then(function(e) {
  onProgress(1); // 1 means indeterminate.
  return e.upload(uri, filename);
}) );

class MetaData {
  static initClass() {
  
    this.prototype.mimetype = 'text/plain';
  }

  constructor(title) {
    this.title = title;
  }

  toString() { return JSON.stringify({title: this.title, mimetype: this.mimetype}); }
}
MetaData.initClass();

class GoogleExporter {

  constructor(gapi) {
    this.gapi = gapi;
    if (!this.gapi) { throw new Error('No api'); }
    if (!Options.get('auth.drive')) { throw new Error(ERR); }
    console.log(this.gapi);
  }

  // Wrapper around gapi.authorize to return a promise
  authorize() { return new Promise((resolve, reject) => {
    const { gapi } = this;
    let timeout = null;
    const opts = {
      client_id: Options.get('auth.drive'),
      scope: SCOPE,
      immediate: false // Immediate means if we expect there to be no user interaction
    };
    // Because of how google loads itself, we may need to wait for it to be initialized, hence
    // the elaborate asynch loop.
    const nextStep = () =>
      gapi.auth.authorize(opts, function(auth) {
        if (auth == null) { return reject(new Error('Not authorized')); }
        if (auth.error) { return reject(new Error(auth.error)); }
        return resolve();
      })
    ;
    const abort = function() {
      clearTimeout(timeout);
      return reject(new Error('timed out')); // no-op if already resolved.
    };
    var checkOrWait = function() {
      clearTimeout(timeout);
      if ((gapi.auth != null ? gapi.auth.authorize : undefined)) { // Cool, we can proceeed.
        return nextStep();
      } else { // not ready yet - come back later...
        return timeout = setTimeout(checkOrWait, 50);
      }
    };
    checkOrWait();
    // Wait up to 5 seconds for gapi to get its act together
    setTimeout(abort, 5000); 
  }); }

  // Wrapper around gapi.client.load to return a promise
  loadClient() { return new Promise((resolve, reject) => this.gapi.client.load("drive", VERSION, resolve)); }

  // Construct the request body from the metadata and the data.
  makeRequestBody(metadata, data) {
    return DELIMITER + METADATA_CT + String(metadata) + DELIMITER + FILE_CT + data + CLOSE_DELIM;
  }

  // Construct a gapi request object, which is a Promise, thus ensuring we wait for success.
  // see: https://developers.google.com/api-client-library/javascript/reference/referencedocs#gapiclientRequest
  makeRequest(body) { return this.gapi.client.request(_.extend({body}, REQ_PARAMS)); }

  // (string, string) -> Promise<string>
  // There is no way to report progress for uploads to Google Drive.
  upload(uri, filename) {
    return this.authorize().then(() => this.loadClient())
                .then(() => Promise.resolve($.get(uri)))
                .then(data => this.makeRequestBody(new MetaData(filename), data))
                .then(body => this.makeRequest(body))
                .then(resp => resp.result.alternateLink);
  }
}
