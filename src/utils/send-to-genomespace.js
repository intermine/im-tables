const _ = require('underscore');
const {Promise} = require('es6-promise');

const Options = require('../options');

const {fromPairs} = require('./query-string');

const getGenomeSpaceUrl = function(uri, fileName) {
  const GenomeSpace = Options.get('Destination.GenomeSpace');
  const pairs = [['uploadUrl', uri], ['fileName', fileName]];
  const qs = fromPairs(pairs);
  return `${ GenomeSpace.Upload }?${ qs }`;
};

const save = (uri, fileName) => new Promise(function(resolve, reject) {
  // Open the GS pop-up interface.
  const win = window.open(getGenomeSpaceUrl(uri, fileName));

  // Yes, technically this is a pointless wrapper function, but
  // it makes the API clearer.
  win.setCallbackOnGSUploadComplete = savePath => resolve(savePath);
  // We don't get sensible errors back, so just construct one.
  win.setCallbackOnGSUploadError = function(savePath) {
    console.log('GSERR', arguments);
    return reject(new Error(`Could not save to ${ savePath }`));
  };
  win.addEventListener('unload', () => reject(new Error('Upload cancelled')));

  return win.focus();
}) ;

module.exports = save;
