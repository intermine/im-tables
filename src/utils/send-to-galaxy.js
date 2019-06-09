// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS201: Simplify complex destructure assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let send;
const _ = require('underscore');
const {Promise} = require('es6-promise');

const Options = require('../options');
const Messages = require('../messages');

// Utils that promise to return some metadata.
const getOrganisms = require('./get-organisms');
const getBranding = require('./branding');
const getResultClass = require('./get-result-class');

const openWindowWithPost = require('./open-window-with-post');
const parseUrl = require('./parse-url');

// Find out which Galaxy to send stuff to, work out all the parameters, and send it off
// in a hidden post form.
module.exports = (send = function(url, filename, onProgress) {
  const Galaxy = Options.get('Destination.Galaxy');
  let uri = (Galaxy.Current != null ? Galaxy.Current : Galaxy.Main);
  if (!/tool_runner$/.test(uri)) { uri += '/tool_runner'; }

  const gettingBranding = getBranding(this.query.service);
  const gettingResultClass = getResultClass(this.query);
  const gettingOrganisms = getOrganisms(this.query);

  return Promise.all([gettingResultClass, gettingOrganisms, gettingBranding])
         .then(getParameters(url, this.query, this.model.format.ext))
         .then(_.partial(openWindowWithPost, uri, 'Upload'));
});

// Turn all the info we have into a single set of Galaxy compatible parameters.
var getParameters = (url, query, ext) => function(...args) {
  let organism;
  const [cls, orgs, branding] = Array.from(args[0]);
  const {URL, params} = parseUrl(url); // one canonical source of truth is best.
  const lists = (Array.from(query.constraints).filter((c) => c.op === 'IN').map((c) => c.value));
  const data_type = ext === 'tsv' ? 'tabular' : ext;
  const currentLocation = window.location.toString().replace(/\?.*$/, ''); // strip query-string
  const tool_id = Options.get('Destination.Galaxy.Tool');
  const name = Messages.getText('export.galaxy.name', {cls, orgs, branding});
  const info = Messages.getText('export.galaxy.info', {query, lists, orgs, currentLocation});
  if (orgs != null) { organism = orgs.join(', '); }

  return _.extend(params, {tool_id, URL, name, info, data_type, organism, URL_method: 'post'});
} ;

// Set the user's preferred galaxy, if they want it to be stored.
send.after = function() {
  const Galaxy = Options.get('Destination.Galaxy');
  if (Galaxy.Current && Galaxy.Save) {
    return this.query.service.whoami().then(function(user) {
      if (user.preferences['galaxy-url'] !== Galaxy.Current) {
        return user.setPreference('galaxy-url', Galaxy.Current);
      }
    });
  } else {
    return Promise.resolve(null);
  }
};

