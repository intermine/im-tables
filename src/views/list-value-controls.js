let ListValueControls;
const _ = require('underscore');
const fs = require('fs');
const {Promise} = require('es6-promise');

const Messages = require('../messages');
const View = require('../core-view');

Messages.set({
  'convalue.BadType': "<%- name %> is of the wrong type (<%- type %>).",
  'convalue.EmptyList': "<%- name %> is empty. This query will always return 0 results",
  'convalue.BadList': `\
You do not have access to list called "<%- name %>". Choose one from the list.\
`
});

const helpers = require('../templates/helpers');
const mustacheSettings = require('../templates/mustache-settings');

const html = fs.readFileSync(__dirname + '/../templates/list-value-controls.html', 'utf8');
const template = _.template(html);
const getOptionValue = list => list.name;
const formatList = function(list) {
  if (list.size) {
    return `${ list.name } (${ list.size } ${ list.typeName }s)`;
  } else {
    return list.name;
  }
};

// Promise to add a typeName property to the list.
// :: Query -> List -> Promise<ExtendedList>
const withDisplayNames = m => function(l) {
  const p = m.makePath(l.type);
  return p.getDisplayName().then(typeName => _.extend(l, {typeName}));
} ;

module.exports = (ListValueControls = (function() {
  ListValueControls = class ListValueControls extends View {
    static initClass() {
  
      this.prototype.className = 'im-list-value-controls';
    }

    initialize({query}) {
      this.query = query;
      super.initialize(...arguments);
      this.initialValue = this.model.get('value');
      this.path = this.model.get('path');
      this.setSuitableLists();
      this.listenTo(this.model, 'change', this.reRender);
      this.listenTo(this.model, 'change:value', this.checkCurrentValue);
      return this.checkCurrentValue();
    }

    checkCurrentValue() {
      const name = this.model.get('value');
      const doesntExist = error => {
        this.model.set({error: new Error(Messages.getText('convalue.BadList', {name}))});
        return this.listenToOnce(this.model, 'change:value', () => this.model.unset('error'));
      };
      const exists = function(list) {
        const err = (() => {
          if (!list.size) {
          return 'convalue.EmptyList';
        } else if (!this.path.isa(list.type)) {
          return 'convalue.BadType';
        }
        })();

        if (err != null) {
          this.model.set({error: new Error(Messages.getText(err, list))});
          return this.listenToOnce(this.model, 'change:value', () => this.model.unset('error'));
        }
      };

      return this.query.service.fetchList(name).then(exists, doesntExist);
    }

    events() {
      return {'change select': 'setList'};
    }

    setList() { return this.model.set({value: this.$('select').val()}); }

    setSuitableLists() { if (!this.model.has('suitableLists')) {
      const success = suitableLists => this.model.set({suitableLists});
      const failed = error => this.model.set({error});
      return this.fetchSuitableLists().then(success, failed);
    } }

    fetchSuitableLists() { // Cache this result, since we don't want to keep fetching it.
      return this.__suitable_lists != null ? this.__suitable_lists : (this.__suitable_lists = this.query.service.fetchLists().then(lists => {
        const selectables = ((() => {
          const result = [];
          for (let l of lists) {             if (l.size && this.path.isa(l.type)) {
              result.push(l);
            }
          }
          return result;
        })());
        return Promise.all(selectables.map(withDisplayNames(this.query.model)));
      }));
    }

    getSuitableLists() {
      const currentValue = {name: this.initialValue};
      const suitableLists = (this.model.get('suitableLists') || []);
      let currentlySelected = _.findWhere(suitableLists, currentValue);
      if (currentlySelected == null) { currentlySelected = currentValue; }
      return _.uniq([currentlySelected].concat(suitableLists), false, 'name');
    }

    template(data) {
      data = _.extend({formatList, getOptionValue, messages: Messages}, helpers, data);
      return template(data);
    }

    getData() {
      const currentValue = this.model.get('value');
      const suitableLists = this.getSuitableLists();
      const isSelected = opt => opt.name === currentValue;
      return {suitableLists, isSelected};
    }
  };
  ListValueControls.initClass();
  return ListValueControls;
})());

