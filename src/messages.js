const Backbone = require('backbone');
const _ = require('underscore');

// HWAT! Do not be tempted to replace this with a loop to build DEFAULTS. That
// would break browserify. You would want to do that, would you?
const actionMessages = require('./messages/actions');
const common = require('./messages/common');

const {numToString, pluralise} = require('./templates/helpers');

const DEFAULTS = [common, actionMessages];

const HELPERS = { // All message templates have access to these helpers.
  formatNumber: numToString,
  pluralise
};

class Messages extends Backbone.Model {

  constructor(...args) {
    super(...args);
    this.getText = this.getText.bind(this);
  }

  initialize() {
    this.cache = {};
    return this.on('change', () => { return this.cache = {}; });
  }

  destroy() {
    this.off();
    return (() => {
      const result = [];
      for (let prop in this) {
        result.push(delete this[prop]);
      }
      return result;
    })();
  }

  getTemplate(key) {
    let templ = (this.cache[key] != null ? this.cache[key] : this.get(key));
    if ((templ != null) && (templ.call == null)) {
      // Don't recompile the template each time
      // also, allow users to supply precompiled or custom templates.
      templ = _.template(templ);
    }
    return this.cache[key] = templ;
  }

  getText(key, args) {
    let left;
    if (args == null) { args = {}; }
    const templ = this.getTemplate(key);
    // Make missing keys really obvious
    return (left = (typeof templ === 'function' ? templ(_.extend({Messages: this}, HELPERS, args)) : undefined)) != null ? left : `!!!No message for ${ key }!!!`;
  }

  // Allows sets of messages to be set with a prefix namespacing them.
  setWithPrefix(prefix, messages) { return (() => {
    const result = [];
    for (let key in messages) {
      const val = messages[key];
      result.push(this.set(`${prefix}.${key}`, val));
    }
    return result;
  })(); }

  defaults() { return _.extend.apply(null, [{}].concat(DEFAULTS)); }
}

module.exports = new Messages;

module.exports.Messages = Messages;
  
