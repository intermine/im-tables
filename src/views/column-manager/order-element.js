// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let OrderElement;
const _ = require('underscore');

const SelectedColumn = require('./selected-column');
const Templates = require('../../templates');

const TEMPLATE_PARTS = [
  'column-manager-position-controls',
  'column-manager-order-direction',
  'column-manager-path-name',
  'column-manager-path-remover'
];

const nextDirection = function(dir) { if (dir === 'ASC') { return 'DESC'; } else { return 'ASC'; } };

module.exports = (OrderElement = (function() {
  OrderElement = class OrderElement extends SelectedColumn {
    static initClass() {
  
      this.prototype.removeTitle = 'columns.RemoveOrderElement';
  
      this.prototype.template = Templates.templateFromParts(TEMPLATE_PARTS);
    }

    modelEvents() { return _.extend(super.modelEvents(...arguments),
      {'change:direction': this.reRender}); }

    events() { return _.extend(super.events(...arguments),
      {'click .im-change-direction': 'changeDirection'}); }

    changeDirection() {
      return this.model.swap('direction', nextDirection);
    }
  };
  OrderElement.initClass();
  return OrderElement;
})());

