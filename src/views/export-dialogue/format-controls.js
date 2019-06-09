/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let FormatControls;
const _ = require('underscore');
const View = require('../../core-view');
const Messages = require('../../messages');
const Templates = require('../../templates');
const LabelView = require('../label-view');
const Formats = require('../../models/export-formats');

class HeadingView extends LabelView {
  static initClass() {
  
    this.prototype.template = _.partial(Messages.getText, 'export.category.Format');
  }
}
HeadingView.initClass();

module.exports = (FormatControls = (function() {
  FormatControls = class FormatControls extends View {
    static initClass() {
  
      this.prototype.tagName = 'form';
  
      this.prototype.template = Templates.template('export_format_controls');
    }

    getData() {
      const types = this.model.get('has');
      const formats = Formats.getFormats(types);
      return _.extend({formats}, super.getData(...arguments));
    }

    events() {
      return {'change input:radio': 'onChangeFormat'};
    }

    onChangeFormat() {
      return this.model.set({format: this.$('input:radio:checked').val()});
    }

    postRender() {
      return this.renderChild('heading', (new HeadingView({model: this.model})), this.$('.im-title'));
    }
  };
  FormatControls.initClass();
  return FormatControls;
})());

