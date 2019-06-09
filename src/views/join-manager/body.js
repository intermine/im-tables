/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let JoinManagerBody;
const _ = require('underscore');
const CoreView = require('../../core-view');
const Templates = require('../../templates');
const ClassSet = require('../../utils/css-class-set');

require('../../messages/joins');

const LINE_PARTS = [
  'join-style',
  'column-manager-path-name',
  'clear',
];

class BtnClasses extends ClassSet {

  constructor(model, style) { super({
    'btn btn-default': true,
    active() { return style === model.get('style'); }
  }); }
}

const otherStyle = function(style) { switch (style) {
  case 'INNER': return 'OUTER';
  case 'OUTER': return 'INNER';
  default: return 'INNER'; // We could throw an error here.
} };

class Join extends CoreView {
  static initClass() {
  
    this.prototype.tagName = 'li';
  
    this.prototype.className = 'list-group-item';
  
    this.prototype.template = Templates.templateFromParts(LINE_PARTS);
  }

  modelEvents() {
    return {'change:style change:parts': this.reRender};
  }

  initialize() {
    super.initialize(...arguments);
    return this.classSets = {
      innerJoinBtn: new BtnClasses(this.model, 'INNER'),
      outerJoinBtn: new BtnClasses(this.model, 'OUTER')
    };
  }

  getData() { return _.extend(super.getData(...arguments), this.classSets); }

  events() {
    return {'click button': this.onButtonClick};
  }

  onButtonClick(e) {
    if (/active/.test(e.target.className)) { return; }
    return this.model.swap('style', otherStyle);
  }
}
Join.initClass();

module.exports = (JoinManagerBody = (function() {
  JoinManagerBody = class JoinManagerBody extends CoreView {
    static initClass() {
  
      this.prototype.template = Templates.template('join-manager-body');
    }

    initState() {
      return this.state.set({explaining: false});
    }

    postRender() {
      this.$group = this.$('.list-group');
      return this.collection.each(m => this.addJoin(m));
    }

    addJoin(model) { if (this.rendered) {
      return this.renderChild(model.id, (new Join({model})), this.$group);
    } }

    removeJoin(model) { return this.removeChild(model.id); }

    events() {
      return {'click .alert-info strong'() { return this.state.toggle('explaining'); }};
    }

    stateEvents() {
      return {'change:explaining': this.onChangeExplaining};
    }

    collectionEvents() {
      return {
        add: this.addJoin,
        remove: this.removeJoin,
        sort: this.reRender
      };
    }

    onChangeExplaining() { if (this.rendered) {
      const p = this.$('.alert-info p');
      const meth = this.state.get('explaining') ? 'slideDown' : 'slideUp';
      return p[meth]();
    } }
  };
  JoinManagerBody.initClass();
  return JoinManagerBody;
})());

