// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS201: Simplify complex destructure assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ColumnHeader;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Collection = require('../../core/collection');
const Templates = require('../../templates');
const Messages = require('../../messages');
const Options = require('../../options');

const ClassSet = require('../../utils/css-class-set');
const sortQueryByPath = require('../../utils/sort-query-by-path');
const onChange = require('../../utils/on-change');

const HeaderModel = require('../../models/header');

// Check that all these can accept a HeaderModel as their model
const FormattedSorting = require('../formatted-sorting');
const SingleColumnConstraints = require('../constraints/single-column');
const DropDownColumnSummary = require('./column-summary');
const OuterJoinDropDown = require('./outer-join-summary');

const {ignore} = require('../../utils/events');

require('../../messages/table'); // Our messages live here.

const ModelReader = (model, attr) => () => model.get(attr);

const getViewPortHeight = () => Math.max(document.documentElement.clientHeight, window.innerHeight || 0);

const getViewPortWidth = () => Math.max(document.documentElement.clientWidth, window.innerWidth || 0);

module.exports = (ColumnHeader = (function() {
  ColumnHeader = class ColumnHeader extends CoreView {
    constructor(...args) {
      {
        // Hack: trick Babel/TypeScript into allowing this before super.
        if (false) { super(); }
        let thisFn = (() => { return this; }).toString();
        let thisName = thisFn.match(/return (?:_assertThisInitialized\()*(\w+)\)*;/)[1];
        eval(`${thisName} = this;`);
      }
      this.showSummary = this.showSummary.bind(this);
      this.showColumnSummary = this.showColumnSummary.bind(this);
      this.showFilterSummary = this.showFilterSummary.bind(this);
      this.toggleColumnVisibility = this.toggleColumnVisibility.bind(this);
      super(...args);
    }

    static initClass() {
  
      this.prototype.Model = HeaderModel;
  
      this.prototype.tagName = 'th';
  
      this.prototype.className = 'im-column-th';
  
      this.prototype.RERENDER_EVENT = onChange([ // All the things that would cause us to re-render.
        'composed',
        'expanded',
        'minimised',
        'numOfCons',
        'outerJoined',
        'parts',
        'path',
        'sortable',
        'sortDirection',
      ]);
  
      this.prototype.template = Templates.template('column-header');
  
      this.prototype.namePopoverTemplate = Templates.template('column_name_popover');
  
      this.prototype.parameters = ['query'];
      this.prototype.optionalParameters = [
        'blacklistedFormatters',
        'expandedSubtables',
      ];
  
      // Default values of optional parameters.
      this.prototype.expandedSubtables = new Collection;
      this.prototype.blacklistedFormatters = new Collection;
    }

    initialize() {
      super.initialize(...arguments);

      this.listenTo(this.query, 'showing:column-summary', this.removeMySummary);

      this.listenTo(Options, 'change:icons', this.reRender);

      return this.createClassSets();
    }

    path() { return this.model.pathInfo(); }

    createClassSets() { // Class sets that are always up-to-date.
      this.classSets = {};
      this.classSets.headerClasses = new ClassSet({
        'im-column-header': true,
        'im-minimised-th': ModelReader(this.model, 'minimised'),
        'im-is-composed': ModelReader(this.model, 'composed'),
        'im-has-constraint': ModelReader(this.model, 'numOfCons')
      });
      return this.classSets.colTitleClasses = new ClassSet({
        'im-col-title': true,
        'im-hidden': ModelReader(this.model, 'minimised')
      });
    }

    // Make sure we are only showing one column summary at once, so make way for
    // other column summaries that are displayed.
    removeMySummary(path) { if (!path.equals(this.model.pathInfo())) {
      this.removeChild('summary');
      return this.$('.dropdown.open').removeClass('open');
    } }

    onSubtableExpanded(node) { if (node.toString().match(this.model.getView())) {
      return this.model.set({expanded: true});
    } }

    onSubtableCollapsed(node) { if (node.toString().match(this.model.getView())) {
      return this.model.set({expanded: false});
    } }

    getData() {
      let parts;
      const array = (parts = this.model.get('parts')),
        adjustedLength = Math.max(array.length, 2),
        ancestors = array.slice(0, adjustedLength - 2),
        penult = array[adjustedLength - 2],
        last = array[adjustedLength - 1];
      const hasAncestors = ancestors.length;
      const parentType = hasAncestors ? 'non-root' : 'root';

      // We re-create because the alternative is needless re-calculation
      // of ancestors and last.
      const penultClasses = new ClassSet({
        'im-title-part im-parent': true,
        'im-root-parent': (!hasAncestors),
        'im-non-root-parent': hasAncestors,
        'im-last': (!last)
      }); // in which case the penult is actually last.

      return _.extend({penultClasses, last, penult}, this.classSets, super.getData(...arguments));
    }

    events() {
      return {
        'click .im-col-sort': 'setSortOrder',
        'click .im-col-minumaximiser': 'toggleColumnVisibility',
        'click .im-col-filters': 'showFilterSummary',
        'click .im-subtable-expander': this.toggleSubTable,
        'click .im-col-remover': 'removeColumn',
        'hidden.bs.dropdown'() { return this.removeChild('summary'); },
        'shown.bs.dropdown': 'onDropdownShown',
        'toggle .im-th-button': 'summaryToggled',
        'click .summary-img': this.showColumnSummary,
        'click .im-col-composed': this.addFormatterToBlacklist
      };
    }

    postRender() {
      this.setTitlePopover();
      this.announceExpandedState();
      return this.activateTooltips();
    }

    activateTooltips() { return this.$('.im-th-button').tooltip({
      placement: 'top',
      container: this.el
    }); }

    onDropdownShown(e) { return _.defer(function() {
      // Reset the right prop, so that the following calculation returns the truth.
      delete e.target.style.right;
      const ddRect = e.target.getBoundingClientRect();
      if (ddRect.left < 0) {
        const right = `${ ddRect.left }px`;
        return e.target.style.right = right;
      }
    }); }

    addFormatterToBlacklist() {
      return this.blacklistedFormatters.add({formatter: this.model.get('formatter')});
    }
    
    announceExpandedState() { if (this.model.get('expanded')) {
      return this.query.trigger('expand:subtables', this.model.get('path'));
    } }

    setTitlePopover() { if (Options.get('TableHeader.FullPathPopoverEnabled')) {
      // title is html - cannot be implemented in the main template.
      return this.$('.im-col-title').popover({
        content: () => this.namePopoverTemplate(this.getData()),
        container: this.el,
        placement: 'bottom',
        html: true
      });
    } }

    summaryToggled(e, isOpen) {
      ignore(e);
      if (e.target !== e.currentTarget) { return; } // Don't listen to bubbled events.
      if (!isOpen) { return this.removeChild('summary'); }
    }

    hideTooltips() { return this.$('.im-th-button').tooltip('hide'); }

    removeColumn(e) {
      ignore(e);
      this.hideTooltips();
      const view = this.model.getView();
      return this.query.removeFromSelect((() => {
        const result = [];
        for (let v of Array.from(this.query.views)) {           if (v.match(view)) {
            result.push(v);
          }
        }
        return result;
      })());
    }

    checkHowFarOver(el) {
      const bounds = this.$el.closest('.im-table-container');
      if ((el.offset().left + 350) >= (bounds.offset().left + bounds.width())) {
        return this.$el.addClass('too-far-over');
      }
    }

    // Generic helper that will show a view in a dropdown menu which it shows.
    showSummary(selector, View, e) {
      ignore(e);
      const $sel = this.$(selector);
      const path = this.path();

      if ($sel.hasClass('open')) {
        this.query.trigger('hiding:column-summary', path);
        $sel.removeClass('open');
        if (this.children.summary != null) {
          this.children.summary.$el.hide();
        } // improves performance with large summaries
        this.removeChild('summary');
        return false;
      } else {
        this.$('.dropdown.open').removeClass('open'); // in case we already have one open.
        this.query.trigger('showing:column-summary', path);
        const summary = new View({query: this.query, model: this.model});
        const $menu = this.$(selector + ' .dropdown-menu');
        if (!$menu.length) { throw new Error(`${ selector } not found`); }
        $menu.empty(); // Whatever we are showing replaces all the content.
        this.renderChild('summary', summary, $menu);
        $sel.addClass('open');
        this.onDropdownShown({target: $menu[0]});
        return true;
      }
    }

    ensureDropdownIsWithinTable(target, selector, minWidth) {
      if (minWidth == null) { minWidth = 360; }
      const elRect = target.getBoundingClientRect();
      const table = this.$el.closest('table')[0];
      if (table == null) { return; }
      const h = getViewPortWidth();
      const $menu = this.$(selector + ' .dropdown-menu');
      if (minWidth >= h) {
        return $menu.addClass('im-fullwidth-dropdown').css({width: h});
      } else {
        $menu.css({width: null});
      }

      if (minWidth >= getViewPortWidth()) { return; }
      const tableRect = table.getBoundingClientRect();
      if ((elRect.left + minWidth)  > tableRect.right) {
        return this.$(selector + ' .dropdown-menu').addClass('dropdown-menu-right');
      }
    }

    showColumnSummary(e) {
      let shown;
      const cls = this.model.get('isReference') ?
        OuterJoinDropDown
      :
        DropDownColumnSummary;

      if (shown = this.showSummary('.im-summary', cls, e)) {
        const h = getViewPortHeight(); // Allow taller tables on larger screens.
        this.$('.im-item-table').css({'max-height': Math.max(350, (h / 2))});
        return this.ensureDropdownIsWithinTable(e.target, '.im-summary');
      }
    }

    showFilterSummary(e) {
      let shown;
      if (shown = this.showSummary('.im-filter-summary', SingleColumnConstraints, e)) {
        return this.ensureDropdownIsWithinTable(e.target, '.im-filter-summary', 500);
      }
    }

    toggleColumnVisibility(e) {
      ignore(e);
      return this.model.toggle('minimised');
    }

    setSortOrder(e) {
      ignore(e);
      if (this.model.get('replaces').length) { // we need to let the user choose
        return this.showSummary('.im-col-sort', FormattedSorting, e);
      } else {
        sortQueryByPath(this.query, this.model.getView());
        return this.$('.im-col-sort').removeClass('open');
      }
    }

    toggleSubTable(e) {
      ignore(e);
      return this.expandedSubtables.toggle(this.model.pathInfo());
    }
  };
  ColumnHeader.initClass();
  return ColumnHeader;
})());

