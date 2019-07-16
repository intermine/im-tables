let ConstraintSummary;
const _ = require('underscore');

const Messages = require('../messages');
const Templates = require('../templates');
const CoreView = require('../core-view');
const {IS_BLANK} = require('../patterns');

const {Query, Model} = require('imjs');

Messages.set({
  'consummary.IsA': 'is a',
  'consummary.NoValue': 'no value'
});

module.exports = (ConstraintSummary = (function() {
  ConstraintSummary = class ConstraintSummary extends CoreView {
    static initClass() {
  
      this.prototype.tagName = 'ol';
  
      this.prototype.className = 'constraint-summary breadcrumb';
  
      this.prototype.template = Templates.template('constraint-summary');
    }

    initialize() {
      super.initialize(...arguments);
      return this.listenTo(Messages, 'change', this.reRender);
    }

    getData() { return _.extend(super.getData(...arguments), {labels: this.getSummary()}); }

    getTitleOp() { return this.model.get('op') || Messages.getText('consummary.IsA'); }

    modelEvents() {
      return {change: this.reRender};
    }

    events() {
      return {'click .label-path'() { return this.state.toggle('showFullPath'); }};
    }

    stateEvents() {
      return {'change:showFullPath': this.toggleFullPath};
    }

    toggleFullPath() {
      return this.$('.label-path').toggleClass('im-show-full-path', !!this.state.get('showFullPath'));
    }

    postRender() {
      return this.toggleFullPath();
    }

    getTitleVal() {
      let needle;
      if (this.model.has('values') && (needle = this.model.get('op'), Array.from(Query.MULTIVALUE_OPS.concat(Query.RANGE_OPS)).includes(needle))) {
        let vals;
        if (vals = this.model.get('values')) {
          if (vals.length === 1) {
            return vals[0];
          } else if (vals.length === 0) {
            return '[ ]';
          } else if (vals.length > 5) {
            return vals.length + " values";
          } else {
            const adjustedLength = Math.max(vals.length, 1),
              first = vals.slice(0, adjustedLength - 1),
              last = vals[adjustedLength - 1];
            return `${ first.join(', ') } and ${ last }`;
          }
        }
      } else if (this.model.has('value')) {
        return this.model.get('value');
      } else {
        let left;
        return (left = this.model.get('typeName')) != null ? left : this.model.get('type'); // Ideally should use displayName
      }
    }

    isLookup() { return this.model.get('op') === 'LOOKUP'; }

    getPathLabel() {
      let left;
      const {title, displayName, path} = this.model.toJSON();
      return {content: String((left = title != null ? title : displayName) != null ? left : path), type: 'path'};
    }

    getSummary() {
      let needle, op;
      const labels = [];

      labels.push(this.getPathLabel());

      if (op = this.getTitleOp()) {
        labels.push({content: op, type: 'op'});
      }

      if ((needle = this.model.get('op'), !Array.from(Query.NULL_OPS).includes(needle))) {
        const val = this.getTitleVal();
        if ((val == null) || IS_BLANK.test(val)) {
          const level = this.model.get('new') ? 'warning' : 'error';
          labels.push({content: 'NoValue', type: level});
        } else {
          labels.push({content: val, type: 'value'});
        }

        if (this.isLookup() && this.model.has('extraValue')) {
          labels.push({content: this.model.get('extraValue'), type: 'extra', icon: 'ExtraValue'});
        }
      }

      return labels;
    }
  };
  ConstraintSummary.initClass();
  return ConstraintSummary;
})());
