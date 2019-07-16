let UndoHistory;
const _ = require('underscore');
const CoreView = require('../core-view');
const Templates = require('../templates');
const Messages = require('../messages');
const Options = require('../options');
const Step = require('./undo-history/step');

const childId = s => `state-${ s.get('revision') }`; 

const ELLIPSIS = -1;

require('../messages/undo');

class Ellipsis extends CoreView {
  static initClass() {
  
    this.prototype.parameters = ['more'];
  
    this.prototype.tagName = 'li';
  
    this.prototype.className = 'im-step im-ellipsis';
  }

  template() { return _.escape(`${ Messages.getText('undo.MoreSteps', {more: this.more}) } ...`); }

  attributes() { return {title: Messages.getText('undo.ShowAllStates', {n: this.more})}; }

  postRender() { return this.$el.tooltip({placement: 'right'}); }

  events() { return {
  click(e) {
      e.preventDefault();
      e.stopPropagation();
      return this.state.toggle('showAll');
    }
  }; }
}
Ellipsis.initClass();

// A step is not trivial is its count differs from the step before it
// (i.e. it introduced some significant change that changed the results).
// The first and last models are always significant.
const notTrivial = function(m, i, ms) {
  const prev = ms[i - 1];
  return (i === 0) || (i === (ms.length - 1)) || (m.get('count') !== prev.get('count'));
};

module.exports = (UndoHistory = (function() {
  UndoHistory = class UndoHistory extends CoreView {
    static initClass() {
  
      this.prototype.parameters = ['collection'];
  
      this.prototype.className = 'btn-group im-undo-history';
  
      this.prototype.template = Templates.template('undo-history');
    }

    events() {
      return {
        'click .btn.im-undo': 'revertToPreviousState',
        'click .im-toggle-trivial': 'toggleTrivial'
      };
    }

    initState() {
      return this.state.set({showAll: false, hideTrivial: false});
    }

    stateEvents() {
      return {
        'change:showAll': this.reRender,
        'change:hideTrivial': this.reRender
      };
    }

    collectionEvents() {
      return {
        remove: this.removeStep,
        'add remove': this.reRender,
        'change:count': this.reRenderIfHidingTrivial
      };
    }

    toggleTrivial(e) {
      e.preventDefault();
      e.stopPropagation();
      return this.state.toggle('hideTrivial');
    }

    revertToPreviousState() { return this.collection.popState(); }

    reRenderIfHidingTrivial() { if (this.state.get('hideTrivial')) {
      return this.reRender();
    } }

    postRender() {
      this.$('.im-toggle-trivial').tooltip({placement: 'right'});
      this.$list = this.$('.im-state-list');
      this.renderStates();
      this.$el.toggleClass('im-has-history', this.collection.size() > 1);
      return this.$el.toggleClass('im-hidden', this.collection.size() <= 1);
    }

    renderStates() {
      const {showAll, hideTrivial} = this.state.toJSON();
      const coll = this.collection;
      const models = hideTrivial ?
        coll.filter(notTrivial)
      :
        coll.models.slice(); // With low level access comes great responsibility.
      const states = models.length;
      const cutoff = Options.get('UndoHistory.ShowAllStatesCutOff');
      const range = (showAll) || (states <= cutoff) ?
        __range__(states - 1, 0, true)
      :
        __range__(states - 1, states - (cutoff - 1), true).concat([ELLIPSIS, 0]);

      return Array.from(range).map((i) =>
        i === ELLIPSIS ?
          this.renderEllipsis(states - cutoff)
        :
          this.renderState(models[i]));
    }

    renderEllipsis(more) {
      return this.renderChild('...', (new Ellipsis({more, state: this.state})), this.$list);
    }

    renderState(s) {
      return this.renderChild((childId(s)), (new Step({model: s})), this.$list);
    }

    removeStep(s) {
      return this.removeChild(childId(s));
    }
  };
  UndoHistory.initClass();
  return UndoHistory;
})());


function __range__(left, right, inclusive) {
  let range = [];
  let ascending = left < right;
  let end = !inclusive ? right : ascending ? right + 1 : right - 1;
  for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
    range.push(i);
  }
  return range;
}