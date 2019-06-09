/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let NewConstraint;
const Messages = require('../messages');

const ActiveConstraint = require('./active-constraint');

Messages.set({
  'conbuilder.Apply': 'Apply'});

module.exports = (NewConstraint = class NewConstraint extends ActiveConstraint {

  initialize() {
    super.initialize(...arguments);
    this.model.set({
      new: true,
      op: (this.model.get('path').isAttribute() ? '=' : 'LOOKUP')
    });
    return this.state.set({
      editing: true});
  }

  render() {
    super.render(...arguments);
    this.$el.addClass("im-new");
    return this;
  }
});
