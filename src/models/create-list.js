/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let CreateListModel;
const _ = require('underscore');
const CoreModel = require('../core-model');
const CoreCollection = require('../core/collection');

const ON_COMMA = /,\s*/;

const trim = s => s.replace(/(^\s+|\s+$)/g, '');

module.exports = (CreateListModel = class CreateListModel extends CoreModel {

  defaults() {
    return {
      name: null,
      description: null
    };
  }

  initialize() {
    this.tags = new CoreCollection;
    if (this.has('tags')) {
      this.tags.reset( Array.from(this.get('tags')).map((tag) => ({id: tag})) );
    }
    this.listenTo(this.tags, 'remove', t => {
      this.trigger('remove:tag', t);
      return this.trigger('change');
    });
    return this.listenTo(this.tags, 'add', t => {
      this.trigger('add:tag', t);
      return this.trigger('change');
    });
  }

  toJSON() { return _.extend(super.toJSON(...arguments), {tags: this.tags.map(t => t.get('id'))}); }

  addTag() {
    const tags = this.get('nextTag');
    if (tags == null) { throw new Error('No tag to add'); }
    this.unset('nextTag');
    return Array.from(trim(tags).split(ON_COMMA)).map((tag) =>
      this.tags.add({id: tag}));
  }

  destroy() {
    if (this.tags != null) {
      this.tags.close();
    }
    return super.destroy(...arguments);
  }
});


