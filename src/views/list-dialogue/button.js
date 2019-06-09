// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ListDialogueButton;
const _ = require('underscore');

const CoreView = require('../../core-view');
const CoreModel = require('../../core-model');
const Collection = require('../../core/collection');
const Templates = require('../../templates');

const ClassSet = require('../../utils/css-class-set');
const Counter = require('../../utils/count-executor');
const PathModel = require('../../models/path');

// The four dialogues of the apocalypse
const AppendPicker = require('./append-from-selection');
const CreatePicker = require('./create-from-selection');
const AppendFromPath = require('./append-from-path');
const CreateFromPath = require('./create-from-path');

require('../../messages/lists');


class Paths extends Collection {
  static initClass() {
  
    this.prototype.model = PathModel;
  }
}
Paths.initClass();

class SelectableNode extends CoreView {
  static initClass() {
  
    this.prototype.parameters = ['query', 'model', 'showDialogue', 'highLight'];
  
    this.prototype.tagName = 'li';
  
    this.prototype.Model = PathModel;
  
    this.prototype.template = Templates.template('list-dialogue-button-node');
  }

  modelEvents() { return {'change:displayName change:typeName': this.reRender}; }

  stateEvents() { return {'change:count': this.reRender}; }

  events() {
    return {
      click: this.openDialogue,
      'mouseenter a'() { return _.defer(() => this.highLight(this.model.get('path'))); },
      'mouseout a'() { return this.highLight(null); }
    };
  }

  initialize() {
    super.initialize(...arguments);
    return this.query.summarise(this.model.get('id'))
          .then(({stats}) => this.state.set({count: stats.uniqueValues}));
  }

  openDialogue() {
    const args = {query: this.query, path: this.model.get('id')};
    return this.showDialogue(args);
  }
}
SelectableNode.initClass();

module.exports = (ListDialogueButton = (function() {
  ListDialogueButton = class ListDialogueButton extends CoreView {
    static initClass() {
  
      this.prototype.tagName = 'div';
  
      this.prototype.className = 'btn-group list-dialogue-button';
  
      this.prototype.template = Templates.template('list-dialogue-button');
  
      this.prototype.parameters = ['query', 'selected'];
  
      this.prototype.optionalParameters = ['tableState'];
  
      this.prototype.tableState = new CoreModel;
    }

    initState() {
      return this.state.set({action: 'create', authenticated: false, disabled: false});
    }

    stateEvents() {
      return {
        'change:action': this.setActionButtonState,
        'change:authenticated': this.setVisible,
        'change:disabled': this.onChangeDisabled
      };
    }

    events() {
      return {
        'click .im-create-action': this.setActionIsCreate,
        'click .im-append-action': this.setActionIsAppend,
        'click .im-pick-items': this.startPicking
      };
    }

    initialize() {
      super.initialize(...arguments);
      this.initBtnClasses();
      this.paths = new Paths;
      // Reversed, because we prepend them in order to the menu.
      this.query.getQueryNodes().reverse().forEach(n => this.paths.add(new PathModel(n)));
      this.query.service.whoami().then(u => this.state.set({authenticated: (!!u)}));
      return Counter.count(this.query) // Disable export if no results or in error.
             .then(count => this.state.set({disabled: count === 0}))
             .then(null, err => this.state.set({disabled: true, error: err}));
    }

    getData() { return _.extend(super.getData(...arguments), this.classSets, {paths: this.paths.toJSON()}); }

    postRender() {
      this.setVisible();
      this.onChangeDisabled();
      const menu = this.$('.dropdown-menu');
      const highLight = p => this.tableState.set({highlitNode: p});
      const showDialogue = args => this.showPathDialogue(args);
      return this.paths.each((model, i) => {
        const node = new SelectableNode({query: this.query, model, showDialogue, highLight});
        return this.renderChild(`path-${ i }`, node, menu, 'prepend');
      });
    }

    onChangeDisabled() { return this.$('.btn').toggleClass('disabled', this.state.get('disabled')); }

    setVisible() { return this.$el.toggleClass('im-hidden', (!this.state.get('authenticated'))); }

    setActionIsCreate(e) {
      e.stopPropagation();
      e.preventDefault();
      return this.state.set({action: 'create'});
    }

    setActionIsAppend(e) {
      e.stopPropagation();
      e.preventDefault();
      return this.state.set({action: 'append'});
    }

    showDialogue(Dialogue, args) {
      const dialogue = new Dialogue(args);
      this.renderChild('dialogue', dialogue);
      const action = this.state.get('action');
      const handler = outcome => result => {
        this.trigger(`${ outcome }:${ action }`, result);
        return this.trigger(outcome, action, result);
      };
      return dialogue.show().then((handler('success')), (handler('failure')));
    }

    showPathDialogue(args) {
      const action = this.state.get('action');
      const Dialogue = (() => { switch (action) {
        case 'append': return AppendFromPath;
        case 'create': return CreateFromPath;
        default: throw new Error(`Unknown action: ${ action }`);
      } })();
      return this.showDialogue(Dialogue, args);
    }

    startPicking() {
      const action = this.state.get('action');
      const args = {collection: this.selected, service: this.query.service};
      const Dialogue = (() => { switch (action) {
        case 'append': return AppendPicker;
        case 'create': return CreatePicker;
        default: throw new Error(`Unknown action: ${ action }`);
      } })();
      this.tableState.set({selecting: true});
      const stopPicking = () => {
        this.tableState.set({selecting: false});
        return this.selected.reset();
      };
      return this.showDialogue(Dialogue, args).then(stopPicking, stopPicking);
    }

    setActionButtonState() {
      const action = this.state.get('action');
      this.$('.im-create-action').toggleClass('active', action === 'create');
      return this.$('.im-append-action').toggleClass('active', action === 'append');
    }

    initBtnClasses() {
      this.classSets = {};
      this.classSets.createBtnClasses = new ClassSet({
        'im-create-action': true,
        'btn btn-default': true,
        active: () => this.state.get('action') === 'create'
      });
      return this.classSets.appendBtnClasses = new ClassSet({
        'im-append-action': true,
        'btn btn-default': true,
        active: () => this.state.get('action') === 'append'
      });
    }
  };
  ListDialogueButton.initClass();
  return ListDialogueButton;
})());

