// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let OuterJoinDropDown;
const _ = require('underscore');
const CoreView = require('../../core-view');
const Templates = require('../../templates');
const Collection = require('../../core/collection');
const PathModel = require('../../models/path');
const DropDownColumnSummary = require('./column-summary');

class SubColumns extends Collection {
  static initClass() {
  
    this.prototype.model = PathModel;
  }
}
SubColumns.initClass();

class SubColumn extends CoreView {
  static initClass() {
  
    this.prototype.parameters = ['showPathSummary'];
  
    this.prototype.className = 'im-subpath im-outer-joined-path';
  
    this.prototype.tagName = 'li';
  
    this.prototype.template = _.template(`\
<a href="#">${ Templates.column_manager_path_name }</a>\
`
    );
  }

  modelEvents() { return {change: this.reRender}; }

  events() { return {click: this.onClick}; }
  
  onClick(e) {
    e.stopPropagation();
    e.preventDefault();
    return this.showPathSummary(this.model);
  }
}
SubColumn.initClass();

module.exports = (OuterJoinDropDown = (function() {
  OuterJoinDropDown = class OuterJoinDropDown extends CoreView {
    static initClass() {
  
      this.prototype.parameters = ['query'];
  
      this.prototype.className = 'im-summary-selector';
  
      this.prototype.tagName = 'ul';
    }

    initialize() {
      super.initialize(...arguments);
      this.subColumns = new SubColumns;
      for (let c of Array.from(this.model.get('replaces'))) {
        this.subColumns.add(this.query.makePath(c));
      }
      return this.path = new PathModel(this.query.makePath(this.model.get('path')));
    }

    getSubpaths() { return this.subColumns; }

    postRender() {
      const paths = this.getSubpaths();
      if (paths.length === 1) { return this.showPathSummary(paths.first()); }
      const showPathSummary = m => this.showPathSummary(m);
      return this.getSubpaths().each((model, i) => {
        return this.renderChild(i, (new SubColumn({model, showPathSummary})));
      });
    }

    showPathSummary(model) {
      this.undelegateEvents(); // stop listening to the element we are ceding control of
      this.removeAllChildren(); // remove all the LIs we added.
      const summ = new DropDownColumnSummary({query: this.query, model});
      this.children.summ = summ; // reference it so it can be reaped.
      summ.setElement(this.el); // pass control of element to new view.
      return summ.render();
    }
  };
  OuterJoinDropDown.initClass();
  return OuterJoinDropDown;
})());
