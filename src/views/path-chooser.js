// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let PathChooser;
const _ = require('underscore');

const Options = require('../options');
const CoreView = require('../core-view');

const Attribute = require('./pathtree/attribute');
const RootClass = require('./pathtree/root');
const Reference = require('./pathtree/reference');
const ReverseReference = require('./pathtree/reverse-reference');

const appendField = (pth, fld) => pth.append(fld);

module.exports = (PathChooser = (function() {
  PathChooser = class PathChooser extends CoreView {
    constructor(...args) {
      {
        // Hack: trick Babel/TypeScript into allowing this before super.
        if (false) { super(); }
        let thisFn = (() => { return this; }).toString();
        let thisName = thisFn.match(/return (?:_assertThisInitialized\()*(\w+)\)*;/)[1];
        eval(`${thisName} = this;`);
      }
      this.createSubFinder = this.createSubFinder.bind(this);
      super(...args);
    }

    static initClass() {
  
      // Model must have 'path'
      this.prototype.parameters = ['model', 'query', 'chosenPaths', 'openNodes', 'view', 'trail'];
  
      this.prototype.tagName = 'ul';
        
      this.prototype.className = 'im-path-chooser';
    }

    initialize() {
      super.initialize(...arguments);
      this.path  = (_.last(this.trail) || this.model.get('root') || this.query.makePath(this.query.root));
      this.cd    = this.path.getEndClass();
      const toPath = appendField.bind(null, this.path);

      // These are all :: [PathInfo]
      for (var fieldType of ['attributes', 'references', 'collections']) {
        this[fieldType] = ((() => {
          const result = [];
          for (let name in this.cd[fieldType]) {
            const attr = this.cd[fieldType][name];
            result.push(toPath(attr));
          }
          return result;
        })());
      }

      this.listenTo(this.model, 'change:allowRevRefs', this.render);
      return this.listenTo(this.openNodes, 'reset', this.render);
    }

    getDepth() { return this.trail.length; }

    showRoot() { return (this.getDepth() === 0) && this.model.get('canSelectReferences'); }

    // Machinery for preserving scroll positions.
    events() { return {scroll: this.onScroll}; }

    onScroll() { if (!this.state.get('ignoreScroll')) {
      const st = this.el.scrollTop;
      const diff = this.state.has('scroll') ? Math.abs(this.state.get('scroll') - st) : 0;
      if ((st !== 0) || (diff < 50)) { // Within the range of manual scrolling, allow it.
        return this.state.set({scroll: st});
      } else { // very likely reset due to tree activity.
        return _.defer(() => { return this.el.scrollTop = this.state.get('scroll'); });
      }
    } }

    startIgnoringScroll() {
      return this.state.set({ignoreScroll: true}); // Ignore during the main render, since it will wipe scroll top.
    }

    startListeningForScroll() {
      if (this.state.has('scroll')) { // Preserve the scroll position.
        this.el.scrollTop = this.state.get('scroll');
      }
      return this.state.set({ignoreScroll: false}); // start listening for scroll again.
    }

    preRender() { return this.startIgnoringScroll(); }

    postRender() {
      let path;
      const showId = Options.get('ShowId');

      if (this.showRoot()) { // then show the root class
        const root = this.createRoot();
        this.renderChild('root', root);
      }

      for (path of Array.from(this.attributes)) {
        if (showId || (path.end.name !== 'id')) {
          const attr = this.createAttribute(path);
          this.renderChild(path.toString(), attr);
        }
      }

      // Same logic for references and collections, but we want references to go first.
      for (path of Array.from(this.references.concat(this.collections))) {
        const ref = this.createReference(path);
        this.renderChild(path.toString(), ref);
      }
      return this.startListeningForScroll();
    }

    createRoot() {
      return new RootClass({query: this.query, model: this.model, chosenPaths: this.chosenPaths, openNodes: this.openNodes, cd: this.cd});
    }

    createAttribute(path) {
      return new Attribute({model: this.model, chosenPaths: this.chosenPaths, view: this.view, query: this.query, trail: this.trail, path});
    }

    createReference(path) {
      const isLoop = this.isLoop(path);
      const allowingRevRefs = this.model.get('allowRevRefs');

      const Ref = isLoop && !allowingRevRefs ? ReverseReference : Reference;
      return new Ref({model: this.model, chosenPaths: this.chosenPaths, query: this.query, trail: this.trail, path, view: this.view, openNodes: this.openNodes, createSubFinder: this.createSubFinder});
    }

    // Inject mechanism for creating a PathChooser to avoid a cyclic dependency.
    createSubFinder(args) {
      return new PathChooser(_.extend({model: this.model, query: this.query, chosenPaths: this.chosenPaths, view: this.view, openNodes: this.openNodes}, args));
    }

    isLoop(path) {
      if ((path.end.reverseReference != null) && this.path.isReference()) {
        if (this.path.getParent().isa(path.end.referencedType)) {
          if (this.path.end.name === path.end.reverseReference) {
            return true;
          }
        }
      }
      return false;
    }
  };
  PathChooser.initClass();
  return PathChooser;
})());


