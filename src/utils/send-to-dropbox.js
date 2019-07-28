const $ = require('jquery');
const {Promise} = require('es6-promise');

const Options = require('../options');
const loadResource = require('./load-resource');

const loadDropbox = () => loadResource('Destination.Dropbox.Library', 'Dropbox');

module.exports = (url, filename, onProgress) => loadDropbox().then(Dropbox =>
  new Promise(function(resolve, reject) {
    Dropbox.appKey = Options.get('auth.dropbox');
    return Dropbox.save({
      files: [ {url, filename} ],
      success:  resolve,
      progress: onProgress,
      cancel:   reject,
      error:    reject
    });
  })
) ;
