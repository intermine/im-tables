/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ColumnManagerTabs;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Templates = require('../../templates');

const ClassSet = require('../../utils/css-class-set');

const tabClassSet = function(tab, state) {
  const defs = {active() { return state.get('currentTab') === tab; }};
  defs[`im-${ tab }-tab`] = true;
  return new ClassSet(defs);
};

module.exports = (ColumnManagerTabs = (function() {
  ColumnManagerTabs = class ColumnManagerTabs extends CoreView {
    static initClass() {
  
      this.TABS = ['view', 'sortorder'];
  
      this.prototype.template = Templates.template('column-manager-tabs');
  
      this.prototype.className = 'im-column-manager-tabs';
    }

    getData() { return _.extend(super.getData(...arguments), {classes: this.classSets}); }

    initState() {
      return this.state.set({currentTab: ColumnManagerTabs.TABS[0]});
    }

    initialize() {
      super.initialize(...arguments);
      return this.initClassSets();
    }

    stateEvents() { return {'change:currentTab': this.reRender}; }

    events() {
      return {
        'click .im-view-tab': 'selectViewTab',
        'click .im-sortorder-tab': 'selectSortOrderTab'
      };
    }

    selectViewTab() { return this.state.set({currentTab: 'view'}); }

    selectSortOrderTab() { return this.state.set({currentTab: 'sortorder'}); }

    initClassSets() {
      this.classSets = {};
      return ['view', 'sortorder'].map((tab) => (tab => {
        return this.classSets[tab] = tabClassSet(tab, this.state);
      })(tab));
    }
  };
  ColumnManagerTabs.initClass();
  return ColumnManagerTabs;
})());

