/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let RootClass;
const _ = require('underscore');

const Icons = require('../../icons');

const Attribute = require('./attribute');

module.exports = (RootClass = (function() {
  RootClass = class RootClass extends Attribute {
    static initClass() {
  
      this.prototype.className = 'im-rootclass';
    }

    initialize(opts) {
      let cd;
      ({cd, openNodes: this.openNodes} = opts);
      opts.trail = [];
      opts.path = opts.query.getPathInfo(cd.name);

      return super.initialize(opts);
    }

    getData() { return _.extend(super.getData(), {icon: Icons.icon('RootClass')}); }

    handleClick(e) {
      if (e != null) {
        e.preventDefault();
      }
      if (e != null) {
        e.stopPropagation();
      }
      if (this.$(e.target).is('i') || (!this.model.get('canSelectReferences'))) {
        if (this.openNodes.size()) {
          return this.openNodes.reset([]);
        } else {
          const {collections, references} = this.path.getType();
          const paths = (Array.from(_.values(references).concat(_.values(collections))).map((r) => this.path.append(r.name)));
          return this.openNodes.reset(paths);
        }
      } else {
        return super.handleClick(e);
      }
    }
  };
  RootClass.initClass();
  return RootClass;
})());
