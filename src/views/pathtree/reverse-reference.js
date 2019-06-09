// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ReverseReference;
const Icons = require('../../icons');

const Reference = require('./reference');

module.exports = (ReverseReference = (function() {
  ReverseReference = class ReverseReference extends Reference {
    static initClass() {
  
      this.prototype.className = 'im-reverse-reference';
    }

    getData() {
      const d = super.getData(...arguments);
      d.icon += ` ${Icons.icon('ReverseRef')}`;
      return d;
    }

    handleClick(e) {
      e.preventDefault();
      e.stopPropagation();
      return this.$el.tooltip('hide');
    }

    render() {
      super.render(...arguments);
      this.$el.attr({title: `Refers back to ${ this.path.getParent().getParent() }`}).tooltip();
      return this;
    }
  };
  ReverseReference.initClass();
  return ReverseReference;
})());

