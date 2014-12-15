#!/bin/sh
':' //; exec "$(command -v nodejs || command -v node)" "$0" "$@"

var _ = require('underscore');
var fs = require('fs');
var util = require('util');

var template = "module.exports = '<%- env.npm_package_version %>';\n";
var content = _.template(template, {variable: 'env'})(process.env);

fs.writeFile('build/version.js', content, function (err) {
  if (err) {
    console.error('Could not write file', err);
    process.exit(1);
  }
});
