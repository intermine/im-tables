// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ExportDialogue;
const _ = require('underscore');
const $ = require('jquery');

const Model = require('../core-model');
const Modal = require('./modal');
const ConstraintAdder = require('./constraint-adder');
const Messages = require('../messages');
const Templates = require('../templates');
const Options = require('../options');

const Formats = require('../models/export-formats');
const RunsQuery = require('../mixins/runs-query');
const Menu = require('./export-dialogue/tab-menu');
const FormatControls = require('./export-dialogue/format-controls');
const RowControls = require('./export-dialogue/row-controls');
const ColumnControls = require('./export-dialogue/column-controls');
const CompressionControls = require('./export-dialogue/compression-controls');
const FlatFileOptions = require('./export-dialogue/flat-file-options');
const JSONOptions = require('./export-dialogue/json-options');
const FastaOptions = require('./export-dialogue/fasta-options');
const DestinationOptions = require('./export-dialogue/destination-options');
const Preview = require('./export-dialogue/preview');

const openWindowWithPost = require('../utils/open-window-with-post');
const sendToDropBox = require('../utils/send-to-dropbox');
const sendToGoogleDrive = require('../utils/send-to-google-drive');
const sendToGalaxy = require('../utils/send-to-galaxy');
const sendToGenomeSpace = require('../utils/send-to-genomespace');

const INITIAL_STATE = {
  doneness: null, // null = not uploading. 0 - 1 = uploading
  tab: 'dest',
  dest: 'download',
  linkToFile: null
};

const FOOTER = ['progress_bar', 'modal_error', 'export_dialogue_footer'];

// The errors users cannot just dismiss, but have to do something to make
// go away.
class UndismissableError {
  static initClass() {
  
    this.prototype.cannotDismiss = true;
  }

  constructor(key) {
    this.key = `export.error.${key}`;
    this.message = Messages.get(this.key);
  }
}
UndismissableError.initClass();

// The model backing this view.
class ExportModel extends Model {

  // The different attributes that define the data we care about.
  defaults() {
    return {
      filename: 'results',
      format: Formats.getFormat('tab'), // Should be one of the Formats
      tablePage: null, // or {start :: int, size :: int}
      start: 0,
      columns: [],
      size: null,
      max: null,
      compress: false,
      compression: 'gzip',
      headers: false,
      jsonFormat: 'rows',
      fastaExtension: null,
      headerType: 'friendly'
    };
  }
}

const isa = target => path => path.isa(target);

// A complex dialogue that delegates the configuration of different
// export parameters to subviews.
module.exports = (ExportDialogue = (function() {
  ExportDialogue = class ExportDialogue extends Modal {
    constructor(...args) {
      super(...args);
      this.onUploadComplete = this.onUploadComplete.bind(this);
      this.onUploadProgress = this.onUploadProgress.bind(this);
      this.onUploadError = this.onUploadError.bind(this);
    }

    static initClass() {
  
      this.include(RunsQuery);
  
      this.prototype.Model = ExportModel;
  
      this.prototype.parameters = ['query'];
  
      this.prototype.modalSize = 'lg';
  
      this.prototype.body = Templates.template('export_dialogue');
  
      // In some future universe we would have template inheritance here,
      // but that is a hack to fake in underscore templates
      this.prototype.footer = Templates.templateFromParts(FOOTER);
    }

    className() { return `im-export-dialogue ${super.className(...arguments)}`; }

    initialize() {
      super.initialize(...arguments);
      // Lift format to definition if supplied.
      if ((this.model.has('format')) && !(this.model.get('format').ext)) {
        this.model.set({format: Formats.getFormat(this.model.get('format'))});
      }
      this.state.set(INITIAL_STATE);
      this.listenTo(this.state, 'change:tab', this.renderMain);
      this.listenTo(this.model, 'change', this.updateState);
      this.listenTo(this.model, 'change:columns', this.setMax);
      this.listenTo(this.model, 'change:format', this.onChangeFormat);
      this.categoriseQuery();
      this.model.set({columns: this.query.views});
      if (this.query.name != null) { this.model.set({filename: this.query.name.replace(/\s+/g, '_')}); }
      this.updateState();
      this.setMax();
      return this.readUserPreferences();
    }

    onChangeFormat() { return _.defer(() => {
      const format = this.model.get('format');
      const activeCols = this.model.get('columns');
      if (format.needs != null ? format.needs.length : undefined) {
        const oldColumns = activeCols.slice();
        const newColumns = [];
        for (let v of Array.from(this.query.views)) {
          var p = this.query.makePath(v).getParent();
          if (_.any(format.needs, needed => p.isa(needed))) {
            newColumns.push(p.append('id').toString());
          }
        }
        const nodecolumns = _.uniq(newColumns);
        this.model.set({nodecolumns});
        const maxCols = format.maxColumns;
        const cs = maxCols ? _.first(nodecolumns, maxCols) : nodecolumns.slice();
        this.model.set({columns: cs});
        return this.model.once('change:format', () => {
          this.model.set({columns: oldColumns});
          return this.model.unset('nodecolumns');
        });
      }
    }); }

    // Read any relevant preferences into state/Options.
    readUserPreferences() { return this.query.service.whoami().then(user => {
      let myGalaxy;
      if (!user.hasPreferences) { return; }
    
      if (myGalaxy = user.preferences['galaxy-url']) {
        return Options.set('Destination.Galaxy.Current', myGalaxy);
      }
    }); }

    setMax() { return this.getEstimatedSize().then(c => this.model.set({max: c})); }

    // This is probably slight overkill, and could be replaced
    // with a function at the cost of complexity. On the plus side, it
    // does not seem to impact performance, and is run only once.
    categoriseQuery() {
      const viewNodes = this.query.getViewNodes();
      const has = {};
      for (let type in this.query.model.classes) {
        const table = this.query.model.classes[type];
        has[type] = _.any(viewNodes, isa(type));
      }
      return this.model.set({has});
    }

    title() { return Messages.getText('ExportTitle', {name: this.query.name}); }

    primaryAction() { return Messages.getText(this.state.get('dest')); }

    primaryIcon() { return this.state.get('dest'); }

    updateState() {
      const {compress, compression, start, size, max, format, columns} = this.model.toJSON();

      const columnDesc = _.isEqual(columns, this.query.views) ?
        Messages.get('All')
      :
        columns.length;

      const rowCount = this.getRowCount();

      const error = columns.length === 0 ?
        new UndismissableError('NoColumnsSelected')
      : start >= max ?
        new UndismissableError('OffsetOutOfBounds')
      :
        null;

      this.state.set(this.model.pick('headers', 'headerType', 'jsonFormat', 'fastaExtension'));
      return this.state.set({
        error,
        format,
        max,
        exportURI: this.getExportURI(),
        rowCount: this.getRowCount(),
        compression: (compress ? compression : null),
        columns: columnDesc
      });
    }

    getRowCount() {
      let {start, size, max} = this.model.pick('start', 'size', 'max');
      if (start == null) { start = 0; } // Should always be a number, but do check
      max -= (start != null ? start : 0); // Reduce the absolute maximum by the offset.
      size = ((size != null) && (size > 0) ? size : max); // Make sure size is not 0 or null.
      return Math.min(max, size);
    }

    getMain() {
      switch (this.state.get('tab')) {
        case 'format': return FormatControls;
        case 'columns': return ColumnControls;
        case 'compression': return CompressionControls;
        case 'column-headers': return FlatFileOptions;
        case 'opts-json': return JSONOptions;
        case 'opts-fasta': return FastaOptions;
        case 'dest': return DestinationOptions;
        case 'rows': return RowControls;
        case 'preview': return Preview;
        default: return FormatControls;
      }
    }

    onUploadComplete(link) {
      return this.state.set({doneness: null, linkToFile: link});
    }

    onUploadProgress(doneness) { return this.state.set({doneness}); }

    onUploadError(err) {
      this.state.set({doneness: null, error: err});
      return console.error(err);
    }

    act() {
      this.onUploadProgress(0);
      // exporter is a function: (string, string, fn) -> Promise<string>
      const exporter = this.getExporter();
      // The @ context of an exporter is {model, state, query}
      const {model, state, query} = this;
      // But it gets read-only versions of them.
      const ctx = {model: model.toJSON(), state: state.toJSON(), query: query.clone()};
      // The parameters are:
      const uri = this.getExportURI();          //:: string
      const file = this.getFileName();          //:: string
      const onProgress = this.onUploadProgress; //:: (number) ->
      const exporting = exporter.call(ctx, uri, file, onProgress);
      exporting.then(this.onUploadComplete, this.onUploadError);

      // Exports can have after actions.
      if (exporter.after != null) {
        const postExport = exporter.after.bind(ctx);
        return exporting.then(postExport, postExport).then(null, e => this.state.set({error: e}));
      }
    }

    getExporter() { switch (this.state.get('dest')) {
      case 'download': return () => Promise.resolve(null); // Download handled by use of an <a/>
      case 'Dropbox': return sendToDropBox;
      case 'Drive': return sendToGoogleDrive;
      case 'Galaxy': return sendToGalaxy;
      case 'GenomeSpace': return sendToGenomeSpace;
      default: throw new Error(`Cannot export to ${ this.state.get('dest') }`);
    } }

    events() {
      const evts = super.events(...arguments);
      evts.keyup = 'handleKeyup';
      return evts;
    }

    handleKeyup(e) {
      if (this.$(e.target).is('input')) { return; }
      switch (e.which) {
        case 40: return (this.children.menu != null ? this.children.menu.next() : undefined);
        case 38: return (this.children.menu != null ? this.children.menu.prev() : undefined);
      }
    }

    renderMain() {
      const Main = this.getMain();
      return this.renderChild('main', (new Main({model: this.model, query: this.query, state: this.state})), this.$('div.main'));
    }

    postRender() {
      this.renderChild('menu', (new Menu({model: this.state})), this.$('nav.menu'));
      this.renderMain();
      this.$el.focus(); // to enable keyboard navigation
      return super.postRender(...arguments);
    }
  };
  ExportDialogue.initClass();
  return ExportDialogue;
})());
