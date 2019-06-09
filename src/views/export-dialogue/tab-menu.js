/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let TabMenu;
const _ = require('underscore');
const View = require('../../core-view');
const Options = require('../../options');
const Templates = require('../../templates');

class Tab {

  constructor(ident, key, formats, groups = null) {
    this.ident = ident;
    if (formats == null) { formats = []; }
    this.formats = formats;
    this.groups = groups;
    this.key = `export.category.${ key }`;
  }

  isFor(format) {
    if (this.formats.length) { return (Array.from(this.formats).includes(format.ext)); }
    if (this.groups != null) { return this.groups[format.group]; }
    return true;
  }
}

const TABS = [
  new Tab('dest', 'Destination'),
  new Tab('opts-json', 'JsonFormat', ['json']),
  new Tab('opts-fasta', 'FastaFormat', ['fasta']),
  new Tab('columns', 'Columns'),
  new Tab('rows', 'Rows', [], {flat: true, machine: true}),
  new Tab('compression', 'Compression'),
  new Tab('column-headers', 'ColumnHeaders', ['tsv', 'csv']),
  new Tab('preview', 'Preview')
];

module.exports = (TabMenu = (function() {
  TabMenu = class TabMenu extends View {
    static initClass() {
  
      this.prototype.tagName = 'ul';
  
      this.prototype.RERENDER_EVENT = 'change';
  
      this.prototype.className = "nav nav-pills nav-stacked im-export-tab-menu";
  
      this.prototype.template = Templates.template('export_tab_menu', {variable: 'data'});
    }

    getTabs() { return ((() => {
      const result = [];
      for (let tab of Array.from(TABS)) {         if (tab.isFor(this.model.get('format'))) {
          result.push(tab);
        }
      }
      return result;
    })()); }

    getData() {
      const tabs = this.getTabs();
      return _.extend({tabs}, super.getData(...arguments));
    }

    setTab(tab) { return () => { if (!this.state.get('pinned')) {
      return this.model.set({tab});
    } }; }

    setPinned(tab) { return () => {
      if (this.state.get('pinned') === tab) {
        this.state.set({pinned: false});
      } else {
        this.state.set({pinned: tab});
      }

      return this.model.set({tab}); // for good measure - should have been set by mouseover
    }; }

    next() {
      const tabs = (Array.from(this.getTabs()).map((t) => t.ident));
      const current = _.indexOf(tabs, this.model.get('tab'));
      let next = current + 1;
      if (next === tabs.length) { next = 0; }
      return this.model.set({tab: tabs[next]});
    }

    prev() {
      const tabs = (Array.from(this.getTabs()).map((t) => t.ident));
      const current = _.indexOf(tabs, this.model.get('tab'));
      const prev = current === 0 ? tabs.length - 1 : current - 1;
      return this.model.set({tab: tabs[prev]});
    }

    events() {
      let ident;
      const evt = Options.get('Events.ActivateTab');
      const events = _.object((() => {
        const result = [];
         for ({ident} of Array.from(TABS)) {           result.push([`${ evt } .im-tab-${ ident }`, (this.setTab(ident))]);
        } 
        return result;
      })());
      if (evt === 'mouseenter') {
        _.extend(events, _.object((() => {
          const result1 = [];
           for ({ident} of Array.from(TABS)) {             result1.push([`click .im-tab-${ ident }`, (this.setPinned(ident))]);
          } 
          return result1;
        })()));
      }
      return events;
    }
  };
  TabMenu.initClass();
  return TabMenu;
})());
    
