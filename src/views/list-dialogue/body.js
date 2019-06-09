// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ListDialogueBody;
const _ = require('underscore');

const CoreView = require('../../core-view'); // base
const Templates = require('../../templates'); // template
const Messages = require('../../messages');
const CreateListModel = require('../../models/create-list'); // model

// Sub-components
const InputWithLabel = require('../../core/input-with-label');
const InputWithButton = require('../../core/input-with-button');
const ListTag = require('./tag');
const TagsApology = require('./tags-apology');

// This view uses the lists messages bundle.
require('../../messages/lists');

module.exports = (ListDialogueBody = (function() {
  ListDialogueBody = class ListDialogueBody extends CoreView {
    static initClass() {
  
      this.prototype.Model = CreateListModel;
  
      this.prototype.template = Templates.template('list-dialogue-body');
  
      this.prototype.$tags = null;
    }

    getData() { return _.extend(super.getData(...arguments)); }

    modelEvents() { return {'add:tag': 'addTag'}; }

    stateEvents() {
      return {'change:minimised': 'toggleOptionalAttributes'};
    }

    events() { return {'click .im-more-options': () => this.state.toggle('minimised')}; } // cache the .im-active-tags selector here

    postRender() { // Render child views.
      this.renderListNameInput();
      this.renderListDescInput();
      return this.renderTags();
    }

    renderTags() {
      this.$tags = this.$('.im-active-tags');
      this.addTags();
      this.renderApology();
      return this.renderTagAdder();
    }

    renderTagAdder() {
      const nextTagView = new InputWithButton({
        model: this.model,
        placeholder: 'lists.AddTag',
        button: 'lists.AddTagBtn',
        sets: 'nextTag'
      });
      this.listenTo(nextTagView, 'act', this.addNextTag);
      return this.renderChildAt('.im-next-tag', nextTagView);
    }

    addTags() { return this.model.tags.each(t => this.addTag(t)); }

    addTag(t) { if (this.rendered) {
      return this.renderChild(`tag-${ t.get('id') }`, (new ListTag({model: t})), this.$tags);
    } }

    toggleOptionalAttributes() {
      const state = this.state.toJSON();
      const $attrs = this.$('.im-optional-attributes');
      if (state.minimised) {
        $attrs.slideUp();
      } else {
        $attrs.slideDown();
      }
      const msg = Messages.getText('lists.ShowExtraOptions', state);
      return this.$('.im-more-options .msg').text(msg);
    }

    renderApology() {
      return this.renderChildAt('.im-apology', (new TagsApology({collection: this.model.tags})));
    }

    renderListNameInput() {
      const nameInput = new InputWithLabel({
        model: this.model,
        attr: 'name',
        label: 'lists.params.Name',
        helpMessage: 'lists.params.help.Name',
        placeholder: 'lists.params.NamePlaceholder',
        getProblem: name => this.validateName(name)
      });
      this.listenTo(nameInput.state, 'change:problem', function() {
        const err = nameInput.state.get('problem');
        return this.state.set({disabled: !!err});
      });
      return this.renderChildAt('.im-list-name', nameInput);
    }
    
    validateName(name) {
      const trimmed = name != null ? name.replace(/(^\s+|\s+$)/g, '') : undefined; // Trim name
      return (!trimmed) || (this.state.get('existingLists')[trimmed]);
    }

    renderListDescInput() { return this.renderChildAt('.im-list-desc', new InputWithLabel({
      model: this.model,
      attr: 'description',
      label: 'lists.params.Desc',
      placeholder: 'lists.params.DescPlaceholder'
    })
    ); }

    // DOM->model data-flow.

    addNextTag() { return this.model.addTag(); }
  };
  ListDialogueBody.initClass();
  return ListDialogueBody;
})());


