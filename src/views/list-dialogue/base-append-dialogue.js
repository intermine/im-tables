// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let BaseAppendDialogue;
const _ = require('underscore');
const {Promise} = require('es6-promise');

const CoreCollection = require('../../core/collection');
const CoreModel = require('../../core-model');
const Messages = require('../../messages');

const BaseCreateListDialogue = require('./base-dialogue');

const AppendToListBody = require('./append-to-list-body');
const AppendToListModel = require('../../models/append-to-list');

const NO_SUITABLE_LISTS = {
  key: 'lists.NoSuitableLists',
  level: 'Warning',
  cannotDismiss: true
};

const LIST_NOT_SUITABLE = {
  key: 'lists.TargetNotCorrectType',
  level: 'Error',
  cannotDismiss: true
};

const TARGET_DOES_NOT_EXIST = {
  key: 'lists.TargetDoesNotExist',
  level: 'Error',
  cannotDismiss: true
};

const NO_TARGET_SELECTED = {
  key: 'lists.NoTargetSelected',
  level: 'Info',
  cannotDismiss: true
};

const theListIsSuitable = path => function(list) {
  if (!path.isa(list.type)) { return (Promise.reject(LIST_NOT_SUITABLE)); }
} ;

const onlyCurrent = ls => _.where(ls, {status: 'CURRENT'});

// Unpack list objects, taking only what we need.
const unpackLists = ls => (() => {
  const result = [];
  for (let {name, type, size} of Array.from(ls)) {     result.push({name, type, size, id: name});
  }
  return result;
})() ;

class PossibleList extends CoreModel {

  defaults() {
    return {
      typeName: null,
      name: null,
      size: 0
    };
  }

  initialize() {
    super.initialize(...arguments);
    return this.fetchTypeName();
  }

  fetchTypeName() {
    const s = this.collection.service;
    const type = this.get('type');
    return s.fetchModel().then(model => model.makePath(type))
                  .then(path => path.getDisplayName())
                  .then(name => this.set({typeName: name}));
  }
}

class PossibleLists extends CoreCollection {
  static initClass() {
  
    this.prototype.model = PossibleList;
  }

  constructor({service}) { {     // Hack: trick Babel/TypeScript into allowing this before super.
    if (false) { super(); }     let thisFn = (() => { return this; }).toString();     let thisName = thisFn.match(/return (?:_assertThisInitialized\()*(\w+)\)*;/)[1];     eval(`${thisName} = this;`);   }   this.service = service; super(); }
}
PossibleLists.initClass();

module.exports = (BaseAppendDialogue = (function() {
  BaseAppendDialogue = class BaseAppendDialogue extends BaseCreateListDialogue {
    static initClass() {
  
      this.prototype.Body = AppendToListBody;
  
      this.prototype.Model = AppendToListModel;
    }

    title() { return Messages.getText('lists.AppendToListTitle', this.getData()); }

    primaryAction() { return Messages.getText('lists.Append'); }

    initialize() {
      super.initialize(...arguments);
      this.listenTo(this.getPossibleLists(), 'remove reset', this.verifyState);
      return this.listenTo(this.getPossibleLists(), 'add reset', this.setTargetIfOnlyOne);
    }

    getPossibleLists() {  return this.possibleLists != null ? this.possibleLists : (this.possibleLists = new PossibleLists({service: this.getService()})); }

    processQuery(query) { return query.appendToList(this.model.get('target')); }
  
    modelEvents() { return _.extend(super.modelEvents(...arguments),
      {'change:target': 'onChangeTarget'}); }

    initState() {
      super.initState(...arguments);
      this.fetchSuitableLists();
      return this.verifyState();
    }

    checkThereAreLists() { if (!this.getPossibleLists().size()) {
      return this.state.set({error: NO_SUITABLE_LISTS});
    } }

    onChangeTarget() {
      this.setTitle();
      return this.verifyState();
    }

    verifyState() {
      this.state.unset('error'); // it will be set down the line.
      this.checkThereAreLists();
      this.verifyTarget();
      return this.verifyTargetExistsAndIsSuitable();
    }

    setTargetIfOnlyOne() {
      const pls = this.getPossibleLists();
      if (pls.length === 1) {
        return this.model.set({target: pls.at(0).get('name')});
      }
    }

    verifyTarget() {
      if (!this.model.get('target')) {
        return this.state.set({error: NO_TARGET_SELECTED});
      }
    }

    onChangeType() {
      super.onChangeType(...arguments);
      return this.fetchSuitableLists();
    }

    getBodyOptions() { return _.extend(super.getBodyOptions(...arguments), {collection: this.getPossibleLists()}); }

    verifyTargetExistsAndIsSuitable() {
      const type = this.getType();
      if (type == null) { return; }
      const target = this.model.get('target');
      if (target == null) { return; }
      const path = type.model.makePath(type.name);

      return this.getService().fetchList(target)
                   .then((theListIsSuitable(path)), (() => TARGET_DOES_NOT_EXIST))
                   .then(null, e => this.state.set({error: e}));
    }

    fetchSuitableLists() {
      const type = this.getType();
      if (type == null) { return this.getPossibleLists().reset(); }

      const path = type.model.makePath(type.name);

      return this.getService().fetchLists()
                   .then(lists => _.filter(lists, list => path.isa(list.type)))
                   .then(onlyCurrent)
                   .then(unpackLists)
                   .then(ls => this.getPossibleLists().reset(ls))
                   .then(null, e => this.state.set({error: e}));
    }
  };
  BaseAppendDialogue.initClass();
  return BaseAppendDialogue;
})());

