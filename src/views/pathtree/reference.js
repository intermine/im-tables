/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let Reference;
const Icons = require('../../icons');
const Attribute = require('./attribute');
const {ignore} = require('../../utils/events');

module.exports = (Reference = class Reference extends Attribute {

  initialize({openNodes, createSubFinder}) {
    this.openNodes = openNodes;
    this.createSubFinder = createSubFinder;
    super.initialize(...arguments);
    this.state.set({collapsed: true});
    this.listenTo(this.openNodes, 'add remove', this.setCollapsed);
    this.listenTo(this.state, 'change:collapsed', this.onChangeCollapsed);
    return this.setCollapsed();
  }

  setCollapsed() {
    // We need a guard because clean up seems to happen in the wrong order.
    return (this.state != null ? this.state.set({collapsed: !this.openNodes.contains(this.path)}) : undefined);
  }

  handleClick(e) {
    ignore(e);
    if (this.$(e.target).is('i') || (!this.model.get('canSelectReferences'))) {
      return this.openNodes.togglePresence(this.path);
    } else {
      return super.handleClick(e);
    }
  }

  getData() {
    const d = super.getData(...arguments);
    d.icon = Icons.icon(this.state.get('collapsed') ? 'ClosedReference' : 'OpenReference');
    return d;
  }

  postRender() {
    return this.onChangeCollapsed();
  }

  onChangeCollapsed() {
    if (this.state.get('collapsed')) {
      return this.removeChild('subfinder');
    } else {
      const trail = this.trail.concat([this.path]);
      const subfinder = this.createSubFinder({trail});
      return this.renderChild('subfinder', subfinder);
    }
  }
});
