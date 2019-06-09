/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let TypeValueControls;
const _ = require('underscore');
const fs = require('fs');
const {Promise} = require('es6-promise');

const Messages = require('../messages');
const View = require('../core-view');

Messages.set({
  'typeconstraints.BadType': `\
<%- type %> is not a legal value for this constraint. Choose another from the list.\
`,
  'typeconstraints.OneClass': `\
<%- name %> is the only legal value this constraint can have. You can always remove it though.\
`
});

const toNamedPath = require('../utils/to-named-path');
const helpers = require('../templates/helpers');

const html = fs.readFileSync(__dirname + '/../templates/type-value-controls.html', 'utf8');

const asOption = ({path, name}) => ({value: path, text: name});

module.exports = (TypeValueControls = (function() {
  TypeValueControls = class TypeValueControls extends View {
    static initClass() {
  
      this.prototype.parameters = ['query', 'model'];
  
      this.prototype.template = _.template(html);
    }

    initialize() {
      super.initialize(...arguments);
      this.model.swap('type', t => t != null ? t : this.model.get('path').getType().name);
      this.listenTo(Messages, 'change', this.reRender);
      this.listenTo(this.state, 'change:subclasses', this.reRender);
      return this.setSubclasses();
    }

    getData() {
      let data, left;
      const type = this.model.get('type');
      return data = {
        select: helpers.select,
        messages: Messages,
        subclasses: (((Array.from((left = this.state.get('subclasses')) != null ? left : [])).map((sc) => asOption(sc)))),
        isSelected(opt) { return type === opt.value; }
      };
    }

    events() {
      return {'change .im-value-type': 'setType'};
    }

    setType() { return this.model.set({type: this.$('.im-value-type').val()}); }

    setSubclasses() { if (!this.model.has('subclasses')) {
      return this.getPossibleTypes().then(subclasses => {
        if (subclasses.length === 1) {
          const msg = Messages.getText('typeconstraints.OneClass', subclasses[0]);
          this.model.set({error: {message: msg, level: 'warning'}});
        }
        return this.state.set({subclasses});
    });
    } }

    // Get the list of sub-types that this constraint could be set to.
    getPossibleTypes() {
      let t;
      const {path, type} = this.model.toJSON();
      const subclasses   = this.query.getSubclasses();
      const schema       = this.query.model;

      delete subclasses[path]; // no point unless we unconstrain it, but we may need other type-cons
      const baseType = schema.getPathInfo(path.toString(), subclasses).getType();
      const subtypes = ((() => {
        const result = [];
        for (t of Array.from(schema.getSubclassesOf(baseType))) {           if (t !== baseType.name) {
            result.push(t);
          }
        }
        return result;
      })());
      const paths = ((() => {
        const result1 = [];
        for (t of Array.from(subtypes)) {           result1.push(schema.makePath(t));
        }
        return result1;
      })());
      const promises = paths.map(toNamedPath);
      if (!Array.from(subtypes).includes(type)) { // Add it there if it isn't one of them, with a warning.
        this.model.set({error: new Error(Messages.getText('typeconstraints.BadType', this.model.toJSON()))});
        promises.push(Promise.resolve({path: type, name: this.model.get('typeName')}));
      }
      return Promise.all(promises);
    }
  };
  TypeValueControls.initClass();
  return TypeValueControls;
})());
