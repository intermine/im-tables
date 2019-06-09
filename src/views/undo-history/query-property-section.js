/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let QueryProperty;
const _ = require('underscore');
const CoreView = require('../../core-view');
const Templates = require('../../templates');
const ClassSet = require('../../utils/css-class-set');

module.exports = (QueryProperty = (function() {
  QueryProperty = class QueryProperty extends CoreView {
    static initClass() {
  
      this.prototype.template = Templates.template('undo-history-step-section');
    }

    labelContent() { throw new Error('NOT IMPLEMENTED'); }

    summaryLabel() { return thow(new Error('NOT IMPLEMENTED')); }

    initState() {
      return this.state.set({open: false});
    }

    initialize() {
      super.initialize(...arguments);
      return this.collectionClasses = new ClassSet({
        'well well-sm': true,
        'im-hidden': () => !this.state.get('open')
      });
    }

    getData() {
      const summaryLabel = _.result(this, 'summaryLabel');
      const count = this.collection.where({removed: false}).length;
      return _.extend(super.getData(...arguments), {count, summaryLabel, labelContent: this.labelContent, collectionClasses: this.collectionClasses});
    }

    events() {
      return {'click .im-section-summary': 'toggleOpen'};
    }

    stateEvents() {
      return {'change:open': this.reRender};
    }

    collectionEvents() {
      return {'change': this.reRender};
    }

    toggleOpen(e) {
      e.stopPropagation();
      e.preventDefault();
      return this.state.toggle('open');
    }
  };
  QueryProperty.initClass();
  return QueryProperty;
})());


