// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let AppendToListBody;
const _ = require('underscore');

const CoreView = require('../../core-view'); // base
const Templates = require('../../templates'); // template
const Messages = require('../../messages');

// Sub-components
const SelectWithLabel = require('../../core/select-with-label');

// This view uses the lists messages bundle.
require('../../messages/lists');

module.exports = (AppendToListBody = (function() {
  AppendToListBody = class AppendToListBody extends CoreView {
    static initClass() {
  
      this.prototype.parameters = ['model', 'collection'];
    }

    postRender() { // Render child views.
      return this.renderListSelector();
    }

    renderListSelector() {
      const selector = new SelectWithLabel({
        model: this.model,
        collection: this.collection,
        attr: 'target',
        label: 'lists.params.Target',
        optionLabel: 'lists.PossibleAppendTarget',
        helpMessage: 'lists.params.help.Target',
        noOptionsMessage: 'lists.append.NoSuitableLists',
        getProblem(target) { return !(target != null ? target.length : undefined); }
      });
      this.listenTo(selector.state, 'change:error', console.error.bind(console));
      return this.renderChild('list-selector', selector);
    }
  };
  AppendToListBody.initClass();
  return AppendToListBody;
})());
      

