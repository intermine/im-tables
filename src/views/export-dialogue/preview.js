/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let Preview;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Messages = require('../../messages');
const Templates = require('../../templates');
const Formats = require('../../models/export-formats');

const RunsQuery = require('../../mixins/runs-query');

const PROPS = {
  compress: null, // HTTP gzip will still take place.
  size: 3
};

module.exports = (Preview = (function() {
  Preview = class Preview extends CoreView {
    static initClass() {
  
      this.include(RunsQuery);
  
      this.prototype.template = Templates.template('export_preview');
    }

    initialize({query}) {
      this.query = query;
      super.initialize(...arguments);
      this.state.set({preview: ''});
      this.setPreview();
      this.listenTo(this.state, 'change:preview', this.reRender);
      return this.listenTo(this.model, 'change:format', this.setPreview);
    }

    setPreview() {
      const format = this.model.get('format');
      if (format.group === 'bio') {
        // bio formats to not support paging, and so we can kill the
        // browser by requesting too much data.
        return this.state.set({preview: 'Previews are not supported for bio-informatics formats'});
      } else {
        return this.runQuery(PROPS).then(resp => {
          if (_.isString(resp)) {
            return this.state.set({preview: resp});
          } else {
            return this.state.set({preview: (JSON.stringify(resp, null, 2))});
          }
        });
      }
    }

    getData() {
      const types = this.model.get('has');
      const formats = Formats.getFormats(types);
      return _.extend({formats}, super.getData(...arguments));
    }

    events() {
      return {'change .im-export-formats select': 'setFormat'};
    }

    setFormat(e) { return this.model.set({format: Formats.getFormat(e.target.value)}); }
  };
  Preview.initClass();
  return Preview;
})());

