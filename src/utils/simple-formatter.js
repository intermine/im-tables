// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {compose, escape} = require('underscore');
const getData = require('./ensure-required-data');

// Produce a callable from a function.
const callable = f => (_, ...args) => f(...Array.from(args || []));

// :: (String, [String], (Object -> String)) -> Formatter
// Takes a class name, a list of fields that the formatted object will need, and a
// function that produces a raw, unescaped string from the complete object
// and returns a Formatter (ie. a callable which takes a Model and Service and
// returns a string.
module.exports = (type, fields, f, classes) =>
  ({
    classes, // css classes
    target: type,     // The target type (also added as a css class)
    replaces: fields,
    call: callable(compose(escape, f, getData(type, fields)))
  })
;
