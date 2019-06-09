/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let FilterDialogue;
const _ = require('underscore');

const CoreView = require('../core-view');
const Modal = require('./modal');
const Messages = require('../messages');
const Templates = require('../templates');

const Constraints = require('./constraints');

require('../messages/constraints');
require('../messages/logic');

class LogicManager extends CoreView {
  static initClass() {
  
    this.prototype.className = 'form im-evenly-spaced im-constraint-logic';
    this.prototype.tagName = 'form';
  
    this.prototype.template = Templates.template('logic-manager-body');
  
    this.prototype.parameters = ['query'];
  }

  initialize() {
    super.initialize(...arguments);
    const codes = (Array.from(this.query.constraints).filter((c) => c.code).map((c) => c.code));
    this.model.set({logic: this.query.constraintLogic});
    return this.state.set({disabled: true, defaultLogic: codes.join(' and ')});
  }

  events() {
    return {
      'change .im-logic': this.setLogic,
      'submit': this.applyChanges
    };
  }

  modelEvents() {
    return {'change:logic': this.setDisabled};
  }

  stateEvents() {
    return {'change:disabled': this.reRender};
  }

  setDisabled() {
    const newLogic = this.model.get('logic');
    const current = this.query.constraintLogic;
    return this.state.set({disabled: (newLogic === current)});
  }

  setLogic(e) {
    return this.model.set({logic: e.target.value});
  }

  applyChanges(e) {
    if (e != null) {
      e.preventDefault();
    }
    if (e != null) {
      e.stopPropagation();
    }
    if (!this.state.get('disabled')) {
      const newLogic = this.model.get('logic');
      this.query.constraintLogic = newLogic;
      return this.query.trigger('change:logic', newLogic);
    }
  }
}
LogicManager.initClass();

var Body = (function() {
  let CODES = undefined;
  Body = class Body extends Constraints {
    static initClass() {
  
      this.prototype.template = Templates.template('active-constraints');
  
      CODES = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    }

    initialize() {
      super.initialize(...arguments);
      return this.assignCodes();
    }

    stateEvents() {
      return {'change:adding': this.reRender};
    }

    assignCodes() {
      let c;
      const constraints = ((() => {
        const result = [];
        for (c of Array.from(this.query.constraints)) {           if (c.op != null) {
            result.push(c);
          }
        }
        return result;
      })());
      if (constraints.length < 2) { return; }
      const codes = CODES.split(''); // New array each time.
      return (() => {
        const result1 = [];
        for (c of Array.from(constraints)) {
          if ((c.code == null)) {
            result1.push((() => {
              let code;
              const result2 = [];
              while ((c.code == null) && (code = codes.shift())) {
                if (!_.any(constraints, con => con.code === code)) { result2.push(c.code = code); } else {
                  result2.push(undefined);
                }
              }
              return result2;
            })());
          }
        }
        return result1;
      })();
    }

    postRender() {
      super.postRender(...arguments);
      const constraints = this.getConstraints();
      if (constraints.length > 1) {
        this.renderChild('logic', new LogicManager({query: this.query}));
      }
      const mth = this.state.get('adding') ? 'slideUp' : 'slideDown';
      return this.$('.im-current-constraints')[mth](400);
    }

    getConAdder() { if (this.state.get('adding')) { return super.getConAdder(...arguments); } }
  };
  Body.initClass();
  return Body;
})();

module.exports = (FilterDialogue = (function() {
  FilterDialogue = class FilterDialogue extends Modal {
    static initClass() {
  
      this.prototype.parameters = ['query'];
    }

    modalSize() { return 'lg'; }

    className() { return super.className(...arguments) + ' im-filter-manager'; }

    title() { return Messages.getText('constraints.Heading', {n: this.query.constraints.length}); }

    initState() {
      return this.state.set({adding: false, disabled: false});
    }

    act() {
      return this.state.set({adding: true, disabled: true});
    }

    dismissAction() { return Messages.getText('Cancel'); }
    primaryAction() { return Messages.getText('constraints.DefineNew'); }

    initialize() {
      super.initialize(...arguments);
      this.listenTo(this, 'shown', this.renderBodyContent);
      return this.listenTo(this.query, 'change:constraints', this.onChangeConstraints);
    }

    onChangeConstraints() {
      this.initState();
      return this.renderTitle();
    }

    renderBodyContent() { if (this.shown) {
      const body = this.$('.modal-body');
      return _.defer(() => this.renderChild('cons', (new Body({state: this.state, query: this.query})), body));
    } }
  };
  FilterDialogue.initClass();
  return FilterDialogue;
})());


