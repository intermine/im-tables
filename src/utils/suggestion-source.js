// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SuggestionSource;
const fs = require('fs');
const _ = require('underscore');

const Options = require('../options');
const Messages = require('../messages');
const Icons = require('../icons');

const mustacheSettings = require('../templates/mustache-settings');
const html = fs.readFileSync(__dirname + '/../templates/too-many-suggestions.html', 'utf8');
const template = _.template(html, mustacheSettings);

module.exports = (SuggestionSource = (function() {
  SuggestionSource = class SuggestionSource {
    static initClass() {
  
      this.prototype.tooMany = '<span></span>';
    }

    constructor(suggestions, total) {
      this.suggest = this.suggest.bind(this);
      this.suggestions = suggestions;
      this.total = total;
      const maxSuggestions = Options.get('MaxSuggestions');
      if (this.total > maxSuggestions) {
        this.tooMany = template({icons: Icons, messages: Messages, extra: total - maxSuggestions});
      }
    }

    suggest(term, cb) {
      let left;
      let s;
      if ((term == null) || (term === '')) {
        return cb((() => {
          const result = [];
          for (s of Array.from(this.suggestions.slice(0, 10))) {             result.push(s);
          }
          return result;
        })());
      }
      const parts = ((left = __guard__(term != null ? term.toLowerCase() : undefined, x => x.split(' '))) != null ? left : []);
      const matches = function({item}) {
        if (item == null) { item = ''; }
        return _.all(parts, p => item.toLowerCase().indexOf(p) >= 0);
      };
      return cb((() => {
        const result1 = [];
        for (s of Array.from(this.suggestions)) {           if (matches(s)) {
            result1.push(s);
          }
        }
        return result1;
      })());
    }
  };
  SuggestionSource.initClass();
  return SuggestionSource;
})());


function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}