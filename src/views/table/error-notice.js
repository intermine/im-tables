// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ErrorNotice;
const _ = require('underscore');
const imjs = require('imjs');

const Options = require('../../options');
const CoreView = require('../../core-view');
const Templates = require('../../templates');
const Messages = require('../../messages');
const indentXML = require('../../utils/indent-xml');
const mailto = require('../../utils/mailto');
const withResource = require('../../utils/with-cdn-resource');
const VERSION = require('../../version');

require('../../messages/error');

const withPrettyPrintOne = _.partial(withResource, 'prettify', 'prettyPrintOne');

const getDomain = function(err) {
  if (/(Type|Reference)Error/.test(String(err))) {
    return 'client'; // clearly our fault.
  } else {
    return 'server';
  }
};

module.exports = (ErrorNotice = (function() {
  ErrorNotice = class ErrorNotice extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-error-notice';
  
      this.prototype.parameters = ['model', 'query'];
  
      this.prototype.template = Templates.template('table-error');
    }

    helpers() { return _.extend(super.helpers(...arguments), {indent: indentXML}); }

    getData() {
      const err = this.model.get('error');
      const time = new Date();
      const subject = Messages.getText('error.mail.Subject');
      const address = this.query.service.help;
      const domain = getDomain(err);

      // Make sure this error is logged.
      console.error(err);

      const href = mailto.href(address, subject, `\
We encountered an error running a query from an
embedded result table.
      
page:       ${ global.location }
service:    ${ this.query.service.root }
error:      ${ err }
date-stamp: ${ time }

-------------------------------
IMJS:       ${ imjs.VERSION }
-------------------------------
IMTABLES:   ${ VERSION }
-------------------------------
QUERY:      ${ this.query.toXML() }
-------------------------------
STACK:      ${ (err != null ? err.stack : undefined) }\
`
      );

      return _.extend(super.getData(...arguments), {domain, mailto: href, query: this.query.toXML()});
    }

    postRender() {
      const query = indentXML(this.query.toXML());
      const pre = this.$('.query-xml');
      return withPrettyPrintOne(ppo => pre.html(ppo(_.escape(query))));
    }

    events() {
      return {
        'click .im-show-query'() {
          this.$('.query-xml').slideToggle();
          return this.$('.im-show-query').toggleClass('active');
        },
        'click .im-show-error'() {
          this.$('.error-message').slideToggle();
          return this.$('.im-show-error').toggleClass('active');
        }
      };
    }
  };
  ErrorNotice.initClass();
  return ErrorNotice;
})());
