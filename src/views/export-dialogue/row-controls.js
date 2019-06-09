/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let RowControls;
const _ = require('underscore');
const View = require('../../core-view');
const LabelView = require('../label-view');
const Messages = require('../../messages');
const Templates = require('../../templates');

class SizeLabel extends LabelView {
  static initClass() {
  
    this.prototype.template = _.partial(Messages.getText, 'export.param.Size');
  }

  getData() { return {size: (this.model.get('size') || Messages.getText('rows.All'))}; }
}
SizeLabel.initClass();

class OffsetLabel extends LabelView {
  static initClass() {
  
    this.prototype.template = _.partial(Messages.getText, 'export.param.Start');
  }
}
OffsetLabel.initClass();

class HeadingLabel extends LabelView {
  static initClass() {
  
    this.prototype.template = _.partial(Messages.getText, 'export.category.Rows');
  }
}
HeadingLabel.initClass();

class ResetButton extends View {
  static initClass() {
  
    this.prototype.RERENDER_EVENT = 'change';
  
    this.prototype.template = Templates.template('export_rows_reset_button');
  }

  getData() { return _.extend(super.getData(...arguments), {isAll: !(this.model.get('start') || this.model.get('size'))}); }

  events() {
    return {
      'click .btn-reset': 'reset',
      'click .im-set-table-page': 'setTablePage'
    };
  }

  reset() {
    return this.model.set({start: 0, size: null});
  }

  setTablePage() {
    return this.model.set(this.model.get('tablePage'));
  }
}
ResetButton.initClass();

module.exports = (RowControls = (function() {
  RowControls = class RowControls extends View {
    static initClass() {
  
      this.prototype.RERENDER_EVENT = 'change:max';
  
      this.prototype.tagName = 'form';
  
      this.prototype.template = Templates.template('export_row_controls');
    }

    initialize() {
      super.initialize(...arguments);
      if (!this.model.has('max')) { this.model.set({max: null}); }
      this.listenTo(this.model, 'change:size', this.updateLabels);
      return this.listenTo(this.model, 'change:size change:start', this.updateInputs);
    }

    events() {
      return {
        'input input[name=size]': 'onChangeSize',
        'input input[name=start]': 'onChangeStart'
      };
    }

    updateInputs() {
      const {start, size, max} = this.model.toJSON();
      this.$("input[name=size]").val((size || max));
      return this.$("input[name=start]").val(start);
    }

    onChangeSize() {
      const size = parseInt(this.$('input[name=size]').val(), 10);
      if ((!size) || (size === this.model.get('max'))) {
        return this.model.set({size: null});
      } else {
        return this.model.set({size});
      }
    }

    onChangeStart() {
      return this.model.set({start: parseInt(this.$('input[name=start]').val(), 10)});
    }

    postRender() {
      this.renderChild('heading', (new HeadingLabel({model: this.state})), this.$('.im-title'));
      this.renderChild('size', (new SizeLabel({model: this.model})), this.$('.size-label'));
      this.renderChild('start', (new OffsetLabel({model: this.model})), this.$('.start-label'));
      return this.renderChild('reset', (new ResetButton({model: this.model})), this.$('.im-reset'));
    }
  };
  RowControls.initClass();
  return RowControls;
})());

