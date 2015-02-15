#!/usr/bin/env node

var fs = require('fs');
var path = require('path');
var less = require('less');
var file = process.argv[2];

if (!file || file === '-h' || file === '--help') {
  fs.createReadStream(path.join(__dirname, 'create-style-usage.txt'))
    .pipe(process.stderr);
  return;
}

var config = {
  paths: [
    process.cwd(),
    path.join(__dirname, '..', 'node_modules')
  ]
};

// Path is either absolute or relative to here.
var fullPath = /^[\/\.]/.test(file) ? file : './' + file;

var content = '@import "./less/main.less";\n' +
              '@import "' + fullPath + '";\n';  

less.render(content, config, function (e, output) {
  if (e) {
    console.error(e.message);
    process.exit(1);
  }
  console.log(output.css);
});
