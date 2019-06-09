// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('underscore');

exports.initTypeaheads = function() { return this._typeaheads != null ? this._typeaheads : (this._typeaheads = []); };

exports.removeTypeAheads = function() {
  if (this._typeaheads == null) { return; }
  return (() => {
    let ta;
    const result = [];
    while (ta = this._typeaheads.shift()) {
      ta.off('typeahead:select');
      ta.off('typeahead:selected');
      ta.off('typeahead:autocompleted');
      ta.off('typeahead:close');
      result.push(ta.typeahead('destroy'));
    }
    return result;
  })();
};

exports.lastTypeahead = function() { return _.last(this._typeaheads != null ? this._typeaheads : []); };

// @param input [jQuery] A jQuery selection to apply a typeahead to.
// @param opts [Object] The typeahead options (see http://twitter.github.io/typeahead.js/examples/)
// @param data [(String, ([String]) ->) ->] Data source
// @param placeholder [String] The new place-holder
// @param cb [(Event, Object) ->] Suggestion handler
exports.activateTypeahead = function(input, opts, data, placeholder, cb, onChange) {
  input.attr({placeholder}).typeahead(opts, data);
  input.on('typeahead:selected', cb);
  input.on('typeahead:select', cb);
  input.on('typeahead:autocompleted', cb);
  if (onChange != null) {
    input.on('typeahead:close', onChange);
  }

  // Keep a track of it, so it can be removed.
  this.initTypeaheads().push(input);

  input.focus();

  return this;
};


