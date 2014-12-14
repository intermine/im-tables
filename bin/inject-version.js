#!/bin/sh
':' //; exec "$(command -v nodejs || command -v node)" "$0" "$@"

var _ = require('underscore');
var fs = require('fs');

var template = _.template("module.exports = '<%- npm_package_version %>';\n");

fs.writeFile('build/version.js', template(process.env), function (err) {
  if (err) {
    console.error('Could not write file', err);
    process.exit(1);
  }
});
