// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {Promise} = require('es6-promise');
const _ = require('underscore');
const $ = require('jquery');

const Options = require('./options');

const CDN = {
  server: 'http://cdn.intermine.org',
  imtables: '/js/intermine/im-tables/2.0.0-beta/', // Ourself, probably.
  tests: {
    fontawesome: /font-awesome/,
    glyphicons: /bootstrap-icons/
  },
  resources: {
    prettify: [
      '/js/google-code-prettify/latest/prettify.js',
      // '/js/google-code-prettify/latest/prettify.css' we have our own style.
    ],
    d3: '/js/d3/3.0.6/d3.v3.min.js',
    glyphicons: "/css/bootstrap/2.3.2/css/bootstrap-icons.css",
    fontawesome: "/css/font-awesome/4.x/css/font-awesome.min.css",
    filesaver: '/js/filesaver.js/FileSaver.min.js'
  }
};

Options.set('CDN', CDN);

const hasStyle = function(pattern) {
  if (pattern == null) { return false; } // No way to tell, assume not.
  const links = _.asArray(document.querySelectorAll('link[rel="stylesheet"]'));
  return _.any(links, link => pattern.test(link.href));
};

const loader = server => function(resource, resourceRegex) {
  // scripts will be loaded, but possibly not executed: hang off a bit
  const resolution = new Promise(function(resolve) { return _.delay(resolve, 50, true); });

  if (/\.css$/.test(resource)) {
    if (hasStyle(resourceRegex)) { return resolution; }
    const link = $('<link type="text/css" rel="stylesheet">');
    link.appendTo('head').attr({href: server + resource});
    return resolution;
  } else {
    const fetch = $.ajax({
      url: server + resource,
      cache: true,
      dataType: 'script'
    });
    return fetch.then(() => resolution);
  }
} ;

exports.load = function(ident) {
  const server = Options.get('CDN.server');
  const conf = Options.get(['CDN', 'resources', ident]);
  const test = Options.get(['CDN', 'tests', ident]);
  const load = loader(server);
  if (!conf) {
    return Promise.reject(`No resource is configured for ${ ident }`);
  } else if (_.isArray(conf)) {
    return Promise.all((Array.from(conf).map((c) => load(c))));
  } else {
    return load(conf, test);
  }
};

