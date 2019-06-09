/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let BaseCreateListDialogue;
const _ = require('underscore');

// Base class
const Modal = require('../modal');
// Text strings
const Messages = require('../../messages');

const CreateListModel = require('../../models/create-list');
const ListDialogueBody = require('./body');

// This view uses the lists messages bundle.
require('../../messages/lists');

const ABSTRACT = function() { throw new Error('not implemented'); };

module.exports = (BaseCreateListDialogue = (function() {
  BaseCreateListDialogue = class BaseCreateListDialogue extends Modal {
    static initClass() {
  
      // :: -> Promise<Query>
      this.prototype.getQuery = ABSTRACT;
  
      // :: -> Promise<int>
      this.prototype.fetchCount = ABSTRACT;
  
      // :: -> PathInfo?
      this.prototype.getType = ABSTRACT;
  
      this.prototype.Model = CreateListModel;
  
      this.prototype.Body = ListDialogueBody;
    }

    // :: -> Service
    getService() { return ABSTRACT; }

    className() { return super.className(...arguments) + ' im-list-dialogue im-create-list'; }

    title() { return Messages.getText('lists.CreateListTitle', this.getData()); }

    primaryAction() { return Messages.getText('lists.Create'); }

    act() {
      return this.getQuery().then(toRun => this.processQuery(toRun))
                 .then(this.resolve, e => this.state.set({error: e}));
    }

    verifyState() { return this.state.set({error: null}); }

    processQuery(query) { return query.saveAsList(this.model.toJSON()); }

    modelEvents() {
      return {'change:type': 'onChangeType'}; // The type can change when selecting items
    }

    onChangeType() { return this.setTypeName(); }

    // If the things that inform the title changes, replace it.
    stateEvents() {
      return {
        'change:typeName change:count': 'setTitle',
        'change:typeName': 'setListName',
        'change:error'() { return console.log(this.state.get('error')); }
      };
    }
  
    setTitle() { return this.$('.modal-title').text(this.title()); }

    setListName() {
      return this.model.set({name: Messages.getText('lists.DefaultName', this.state.toJSON())});
    }

    initState() {
      this.state.set({existingLists: {}, minimised: _.result(this, 'initiallyMinimised')});
      this.setTypeName();
      this.setCount();
      this.checkAuth();
      // you cannot overwrite your own lists. You can shadow everyone elses.
      return this.getService().fetchLists()
                   .then(ls => _.where(ls, {authorized: true}))
                   .then(ls => _.groupBy(ls, 'name'))
                   .then(existingLists => this.state.set({existingLists}));
    }

    setCount() {
      return this.fetchCount().then(count => this.state.set({count}))
                   .then(null, e => this.state.set({error: e}));
    }

    setTypeName() {
      return __guard__(this.getType(), x => x.getDisplayName()
                 .then(typeName => this.state.set({typeName}))
                 .then(null, e => this.state.set({error: e})));
    }

    checkAuth() { return this.getService().whoami().then(null, () => {
      return this.state.set({error: {level: 'Error', key: 'lists.error.MustBeLoggedIn'}});
  }); }

    getBodyOptions() { return {model: this.model, state: this.state}; }

    postRender() {
      super.postRender(...arguments);
      return this.renderChild('body', (new this.Body(this.getBodyOptions())), this.$('.modal-body'));
    }
  };
  BaseCreateListDialogue.initClass();
  return BaseCreateListDialogue;
})());


function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}