// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let Pagination;
const SELECT_LIMIT = 200; // for more than 200 pages move to form

const _ = require('underscore');
const fs = require('fs');

const View = require('../../core-view');
const Paging = require('./paging');

const html = fs.readFileSync(__dirname + '/../../templates/pagination.mtpl', 'utf8');

const strip = s => s.replace(/\s+/g, '');

const ensureNumber = function(raw) {
  if (typeof raw === 'string') { return (parseInt((strip(raw)), 10)); } else { return raw; }
};

module.exports = (Pagination = (function() {
  Pagination = class Pagination extends View {
    static initClass() {
    
      this.include(Paging);
  
      this.prototype.tagName = 'nav';
  
      this.prototype.className = 'im-table-pagination im-table-control';
  
      this.prototype.RERENDER_EVENT = 'change:start change:count change:size';
  
      this.prototype.template = _.template(html);
    }

    modelEvents() {
      return {'change:count': this.setVisible};
    }
  
    getData() {
      let data;
      const {start, size, count} = this.model.toJSON();
      const max = this.getMaxPage();
      return data = {
        max,
        min: 1,
        size,
        currentPage: this.getCurrentPage(),
        gotoStart: (start === 0 ? 'disabled' : undefined),
        goFiveBack: (start < (5 * size) ? 'disabled' : undefined),
        goOneBack: (start < size ? 'disabled' : undefined),
        gotoEnd: (start >= (count - size) ? 'disabled' : undefined),
        goFiveForward: (start >= (count - (6 * size)) ? 'disabled' : undefined),
        goOneForward: (start >= (count - size) ? 'disabled' : undefined),
        selected(i) { return start === (i * size); },
        useSelect: (max <= SELECT_LIMIT)
      };
    }

    postRender() {
      this.$('li').tooltip({placement: 'top'});
      return this.setVisible();
    }

    setVisible() {
      const max = this.getMaxPage();
      return this.$el.toggleClass('im-hidden', max < 2);
    }

    events() {
      return {
        'submit .im-page-form': 'pageFormSubmit',
        'click .im-current-page a': 'clickCurrentPage',
        'change .im-page-form select': 'goToChosenPage',
        'blur .im-page-form input': 'pageFormSubmit',
        'click .im-goto-start': () => this.goTo(0),
        'click .im-go-back-5': () => this.goBack(5),
        'click .im-go-back-1': () => this.goBack(1),
        'click .im-go-fwd-5': () => this.goForward(5),
        'click .im-go-fwd-1': () => this.goForward(1),
        'click .im-goto-end': () => this.goTo((this.getMaxPage() - 1) * this.model.get('size'))
      };
    }

    goToChosenPage(e) {
      const start = ensureNumber(this.$(e.target).val());
      return this.goTo(start);
    }

    clickCurrentPage(e) {
      const size = this.model.get('size');
      const total = this.model.get('count');
      if (size >= total) { return; }
      this.$(e.target).hide();
      return this.$('form').show().find('input').focus();
    }

    pageFormSubmit(e) {
      if (e != null) {
        e.stopPropagation();
      }
      if (e != null) {
        e.preventDefault();
      }
      const pageForm = this.$('.im-page-form');
      const input = this.$('.im-page-form input');
      if (input.size()) {
        const destination = ensureNumber(input[0].value);
        if (destination >= 1) {
          const page = Math.min(this.getMaxPage(), destination);
          this.goTo((page - 1) * this.model.get('size'));
          this.$('.im-current-page > a').show();
          return pageForm.hide();
        } else {
          pageForm.find('.control-group').addClass('error');
          return inp.val(null);
        }
      }
    }
  };
  Pagination.initClass();
  return Pagination;
})());
