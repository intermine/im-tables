// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let FilterDialogue;
const _ = require('underscore');

const CoreView = require('../core-view');
const Messages = require('../messages');
const Modal = require('./modal');
const Body = require('./join-manager/body');
const Joins = require('../models/joins');

require('../messages/joins');

// Simple flat array equals
const areEql = (xs, ys) => (xs.length === ys.length) && (_.all(xs, (x, i) => x === ys[i]));

module.exports = (FilterDialogue = (function() {
  FilterDialogue = class FilterDialogue extends Modal {
    static initClass() {
  
      this.prototype.parameters = ['query'];
    }

    className() { return super.className(...arguments) + ' im-join-manager'; }

    title() { return Messages.getText('joins.Heading'); }
    dismissAction() { return Messages.getText('Cancel'); }
    primaryAction() { return Messages.getText('modal.ApplyChanges'); }

    initialize() {
      super.initialize(...arguments);
      this.joins = Joins.fromQuery(this.query);
      return this.listenTo(this.joins, 'change:style', this.setDisabled);
    }

    initState() {
      return this.state.set({disabled: true});
    }

    act() { if (!this.state.get('disabled')) {
      const newJoins = this.joins.getJoins();
      this.query.joins = newJoins;
      this.query.trigger('change:joins', newJoins);
      return this.resolve(newJoins);
    } }

    setDisabled() {
      const current = _.keys(this.joins.getJoins());
      const initial = ((() => {
        const result = [];
        for (let p in this.query.joins) {
          const s = this.query.joins[p];
          if (s === 'OUTER') {
            result.push(p);
          }
        }
        return result;
      })());
      current.sort();
      initial.sort();
      return this.state.set({disabled: (areEql(current, initial))});
    }

    postRender() {
      super.postRender(...arguments);
      const body = this.$('.modal-body');
      return this.renderChild('cons', (new Body({collection: this.joins})), body);
    }
  };
  FilterDialogue.initClass();
  return FilterDialogue;
})());

