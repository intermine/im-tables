/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS204: Change includes calls to have a more natural evaluation order
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let PageSizer;
const _  = require('underscore');

const Paging = require('./paging');
const HasDialogues = require('../has-dialogues');
const CoreView = require('../../core-view');
const Templates = require('../../templates');
const Events = require('../../events');

// Dialogues
const NewFilterDialogue = require('../new-filter-dialogue');
const ExportDialogue = require('../export-dialogue');
const LargeTableDisuader = require('./large-table-disuader');

// TODO This needs a test/index

module.exports = (PageSizer = (function() {
  PageSizer = class PageSizer extends CoreView {
    static initClass() {
    
      this.include(Paging);
      this.include(HasDialogues);
  
      this.prototype.tagName = 'form';
      this.prototype.className = "im-page-sizer im-table-control form-inline";
  
      this.prototype.sizes = [[10], [25], [50], [100], [250]]; // [0, 'All']]
  
      this.prototype.parameters = ['getQuery'];
  
      this.prototype.template = Templates.template('page_sizer');
  
      // An arbitrarily chosen number above which we should be skeptical about the
      // user's judgement. There isn't a huge amount of sense in showing 250 rows on
      // one page - and it will just tax their browser.
      this.prototype.pageSizeFeasibilityThreshold = 250;
    }

    // We need the query because we will pass it on to modal dialogues we open.
    initialize() {
      let needle;
      super.initialize(...arguments);
      const size = this.model.get('size');
      if ((size != null) && (needle = size, !Array.from(((() => {
        const result = [];
        for (let [s] of Array.from(this.sizes)) {           result.push(s);
        }
        return result;
      })())).includes(needle))) {
        return this.sizes = [[size, size]].concat(this.sizes); // assign, don't mutate
      }
    }

    events() {
      return {
        'submit': Events.suppress,
        'change select': 'changePageSize'
      };
    }

    modelEvents() {
      return {
        'change:size'(m, v) { return this.$('select').val(v); },
        'change:count': this.reRender
      };
    }

    // Determine the selected size and then apply it.
    // If the size is large enough to be potentially problematic, then first check
    // with the user about what to do, where the options include paging about,
    // adding constraints, exporting data or aborting completely.
    changePageSize(evt) {
      const input   = this.$(evt.target);
      const size    = parseInt(input.val(), 10);
      const oldSize = this.model.get('size');
      const accept = (() => this.model.set({size}));
      if (!this.aboveSizeThreshold(size)) { return accept(); } // No need for confirmation.
      const pending = this.whenAcceptable(size).then(action => {
        if (action === 'accept') { return accept(); }
        input.val(oldSize);
        switch (action) {
          case 'back': return this.goBack(1);
          case 'forward': return this.goForward(1);
          case 'constrain': return this.openDialogue(new NewFilterDialogue({query: this.getQuery()}));
          case 'export': return this.openDialogue(ExportDialogue({query: this.getQuery()}));
          default: return console.debug('dismissed dialogue', action);
        }
      });

      return pending.then(null, e => console.error('Error handling dialogues', e));
    }

    // If the new page size is potentially problematic, then check with the user
    // first, rolling back if they see sense. Otherwise, change the page size
    // without user interaction.
    // @param size the requested page size.
    // @return Promise resolved if the new size is acceptable
    whenAcceptable(size) { return this.openDialogue(new LargeTableDisuader({model: {size}})); }

    getData() {
      const count = this.model.get('count');
      const size = this.model.get('size');
      const sizes = ((() => {
        const result = [];
        for (let s of Array.from(this.sizes)) {           if (((count == null)) || (s[0] < count)) {
            result.push(s);
          }
        }
        return result;
      })());

      // If the total count is less than the highest threshold...
      if (sizes.length && (count < this.sizes[this.sizes.length - 1][0])) {
        const found = _.find(sizes, next => next[0] === count);
        // Is our total count one of the page sizes? If so then mutate its label.
        if (found) { 
            found[1]+= found[0] + " (All)";
        } else {
          sizes.push([count, `${count} (All)`]);
        }
      }
      return {size, sizes};
    }

    // Check if the given size could be considered problematic
    //
    // A size if problematic if it is above the preset threshold, or if it 
    // is a request for all results, and we know that the count is large.
    // @param size The size to assess.
    aboveSizeThreshold(size) {
      if (size && (size >= this.pageSizeFeasibilityThreshold)) {
        return true;
      }
      if (!size) { // falsy values null, 0 and '' are treated as all
        const total = this.model.get('count');
        return total >= this.pageSizeFeasibilityThreshold;
      }
      return false;
    }
  };
  PageSizer.initClass();
  return PageSizer;
})());
