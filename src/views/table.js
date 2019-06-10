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
let Table;
const _ = require('underscore');

const CoreView = require('../core-view');
const Options = require('../options');
const Templates = require('../templates');
const Messages = require('../messages');
const Collection = require('../core/collection');
const CoreModel = require('../core-model');
const Types = require('../core/type-assertions');

// Data models.
const TableModel      = require('../models/table');
const ColumnHeaders   = require('../models/column-headers');
const UniqItems       = require('../models/uniq-items');
const RowsCollection  = require('../models/rows');
const SelectedObjects = require('../models/selected-objects');
const History         = require('../models/history');

const CellModelFactory = require('../utils/cell-model-factory');
const TableResults = require('../utils/table-results');

// The sub-views that render the table state.
const ResultsTable = require('./table/inner');
const ErrorNotice = require('./table/error-notice');
const Pagination = require('./table/pagination');
const PageSizer = require('./table/page-sizer');
const TableSummary = require('./table/summary');

require('../messages/table');

const UNKNOWN_ERROR = {
  message: 'Unknown error',
  key: 'error.Unknown'
};

module.exports = (Table = (function() {
  Table = class Table extends CoreView {
    constructor(...args) {
      super(...args);
      this.setSelecting = this.setSelecting.bind(this);
      this.unsetSelecting = this.unsetSelecting.bind(this);
      this.canUseFormatter = this.canUseFormatter.bind(this);
    }

    static initClass() {
  
      // The data model for the table.
      this.prototype.Model = TableModel;
  
      this.prototype.className = "im-table-container";
  
      this.prototype.parameters = [
        'history',        // History of states, tells us the current query.
        'selectedObjects' // currently selected entities
      ];
  
      this.prototype.optionalParameters = [
        'model', // This is just by way of documentation - you can inject the model.
        'columnHeaders', // The column headers
        'blacklistedFormatters' // The formatters you do not like
      ];
  
      this.prototype.parameterTypes = {
        history: (new Types.InstanceOf(History, 'History')),
        selectedObjects: (new Types.InstanceOf(SelectedObjects, 'SelectedObjects'))
      };
  
      this.prototype.cellModelFactory = null;
    }

    // Convenience for creating tables from the outside.
    static create({query, model}) {
      Types.assertMatch(Types.Query, query);
      if (model == null) { model = new TableModel; }
      const history = new History;
      const selectedObjects = new SelectedObjects(query.service);
      history.setInitialState(query);
      return new Table({history, model, selectedObjects}); // initialised in Table::onChangeQuery
    }

    // @param query The query this view is bound to.
    // @param selector Where to put this table.
    initialize() {
      super.initialize(...arguments);
      // columnHeaders contains the header information.
      if (this.columnHeaders == null) { this.columnHeaders = new ColumnHeaders; }
      // Formatters we are not allowed to use.
      if (this.blacklistedFormatters == null) { this.blacklistedFormatters = new UniqItems; }
      // rows contains the current rows in the table
      this.rows = new RowsCollection;

      this.listenTo(this.history, 'changed:current', this.onChangeQuery);
      this.listenTo(this.blacklistedFormatters, 'reset add remove', this.buildColumnHeaders);
      this.listenTo(this.columnHeaders, 'change:minimised', this.onChangeHeaderMinimised);

      return this.onChangeQuery();
    }

    onChangeQuery() {
      // save a reference, just to make life easier.
      const {service, model} = (this.query = this.history.getCurrentQuery());

      // A cell model factory for creating cell models
      // does not need rebuilding.
      if (this.cellModelFactory == null) { this.cellModelFactory = new CellModelFactory(service, model); }
      this.buildColumnHeaders();

      // We wait for the version not because it is needed but because it allows
      // us to diagnose connectivity problems before running a big query.
      return this.fetchVersion().then(() => {
        this.query.count((error, count) => this.model.set({error, count}));
        return this.setFreshness();
      }); // Triggers page fill; see model events.
    }

    // Always good to know the API version. We
    // aren't currently using it for anything, but it
    // is a chance to fail very early and cheaply
    // if we cannot access the web-service.
    fetchVersion() {
      return this.query.service
            .fetchVersion()
            .then(version => this.model.set({version}))
            .then(null, e => onConnectionError(e));
    }

    onConnectionError(e) {
      const err = new Error('Could not connect to server');
      err.key = 'error.ConnectionError';
      return this.model.set({error: err});
    }

    // We fetch data if the query or the page changes.
    // When we fetch data because the page changed we just overlay the
    // table. When the query itself changed we reset back to fetching
    // and run back through the table life-cycle phases.
    modelEvents() {
      return {
        'change:freshness change:start change:size': this.fillRows,
        'change:start change:size': this.overlayTable,
        'change:fill': this.removeOverlay,
        'change:freshness': this.resetPhase,
        'change:phase': this.onChangePhase,
        'change:error': this.onChangeError,
        'change:count': this.onChangeCount
      };
    }

    onChangePhase() {
      this.removeOverlay();
      return this.reRender();
    }

    onChangeCount() {
      const {start, size, count} = this.model.pick('start', 'count', 'size');
      if (start >= count) { // This can happen if we change constraints and the result set shrinks.
        return this.model.set({start: (Math.max(0, count - size))});
      }
    }

    resetPhase() { return this.model.set({phase: 'FETCHING'}); }

    onChangeError() { if (this.model.get('error')) { return this.model.set({phase: 'ERROR'}); } }

    remove() { // remove self, and all children, and remove listeners
      this.cellModelFactory.destroy();
      delete this.cellModelFactory;
      return super.remove(...arguments);
    }

    // Write the change in minimised state to the table model
    onChangeHeaderMinimised(m) {
      const path = this.query.makePath(m.get('path'));
      const minimisedCols = this.model.get('minimisedColumns');

      if (m.get('minimised')) {
        return minimisedCols.add(path);
      } else {
        return minimisedCols.remove(path);
      }
    }

    setSelecting() { return this.model.set({selecting: true}); }

    unsetSelecting() { return this.model.set({selecting: false}); }

    canUseFormatter(formatter) {
      return (formatter != null) && (!this.blacklistedFormatters.contains(formatter));
    }

    // Anything that can bust the cache should go in here.
    // As of this point, that just means the state of the query,
    // which can be represented as an (xml) string.
    setFreshness() { return this.model.set({freshness: this.query.toXML()}); }

    // Set the column headers correctly for the current state of the query,
    // setting the minimised state to respect the state of model.minimisedColumns
    buildColumnHeaders() {
      const silently = {silent: true};
      const minimisedCols = this.model.get('minimisedColumns');
      const isMin = ch => minimisedCols.contains(this.query.makePath(ch.get('path')));

      this.columnHeaders.setHeaders(this.query, this.blacklistedFormatters);
      return this.columnHeaders.forEach(ch => ch.set({minimised: (isMin(ch))}, silently));
    }

    // Request some rows, using a cache as an intermediary, and then fill
    // our rows collection with the result, and then record how successful
    // we were, finally bumping the fill count.
    fillRows() {
      const {start, size} = this.model.pick('start', 'size');
      const success = () => this.model.set({phase: 'SUCCESS'});
      const error   = e => { if (e == null) { e = UNKNOWN_ERROR; } return this.model.set({phase: 'ERROR', error: e}); };

      return TableResults.getCache(this.query)
                  .fetchRows(start, size)
                  .then(rows => this.fillRowsCollection((rows)))
                  .then(success, error)
                  .then(this.model.filled, this.model.filled);
    }

    // Take the rows returned from somewhere (the cache, usually),
    // and then turn the data into cell models and stuff them in turn
    // into rows.
    fillRowsCollection(rows) {
      const createModel = this.cellModelFactory.getCreator(this.query);
      const offset = this.model.get('start');
      // The ID lets us use set for efficient updates.
      const models = rows.map((row, i) => {
        return {
          id: `${ this.query.toXML() }#${ offset + i }`,
          index: (offset + i),
          query: this.query.toXML(), // group cache key.
          cells: ((Array.from(row).map((c) => createModel(c))))
        };
      });

      return this.rows.set(models);
    }

    overlayTable() {
      if (!(this.children.inner != null ? this.children.inner.rendered : undefined)) { return; }

      const table = this.children.inner.$el;
      const elOffset = this.$el.offset();
      const tableOffset = table.offset();

      this.removeOverlay();

      this.overlay = document.createElement('div');
      this.overlay.className = 'im-table-overlay im-hidden';

      const h1 = this.make('h1', {}, Messages.getText('table.OverlayText'));
      h1.style.top = `${ table.height() / 2 }px`;
      this.overlay.appendChild(h1);

      this.el.appendChild(this.overlay);

      return _.delay((() => (this.overlay != null ? this.overlay.classList.remove('im-hidden') : undefined)), 100);
    }

    removeOverlay() {
      if (this.overlay != null) { this.el.removeChild(this.overlay); }
      return delete this.overlay;
    }

    // Rendering logic
 
    template() { switch (this.model.get('phase')) {
      case 'FETCHING': return this.renderFetching();
      case 'ERROR': return this.renderError();
      case 'SUCCESS': return this.renderTable();
      default: throw new Error(`Unknown phase: ${ this.model.get('phase') }`);
    } }

    // What we render when we are fetching data.
    renderFetching() {
      return Templates.template('table-building')(this.getBaseData());
    }

    // A helpful and contrite message.
    renderError() {
      let e;
      this.removeChild('error');
      this.children.error = (e = new ErrorNotice({query: this.query, model: this.model}));
      return e.render().el;
    }

    // The actual data table.
    renderTable() {
      const frag = document.createDocumentFragment();

      this.renderWidgets(frag);

      const table = new ResultsTable(_.extend(_.pick(this, ResultsTable.prototype.parameters),
        {tableState: this.model})
      );

      this.renderChild('inner', table, frag);

      return frag;
    }

    // There is some justification for turning the following methods
    // into their own class.
    renderWidgets(container) {
      if (container == null) { container = this.el; }
      const widgets = _.chain(Options.get('TableWidgets'))
                 .map(({enabled, index}, name) => ({name, index, enabled}))
                 .where({enabled: true})
                 .sortBy('index')
                 .pluck('name')
                 .value();
    
      if (widgets.length) { // otherwise don't bother appending anything.
        const widgetDiv = document.createElement('div');
        widgetDiv.className = 'im-table-controls';
        const clear = document.createElement('div');
        clear.style.clear = 'both';
        for (let widgetName of Array.from(widgets)) {
          if (`place${ widgetName }` in this) {
            const method = `place${ widgetName }`;
            this[ method ]( widgetDiv );
          }
        }
        widgetDiv.appendChild(clear);
        return container.appendChild(widgetDiv);
      }
    }

    renderWidget(name, container, Child) {
      const component = new Child({model: this.model, getQuery: () => this.history.getCurrentQuery()});
      return this.renderChild(name, component, container);
    }

    placePagination(widgets) {
      return this.renderWidget('pagination', widgets, Pagination);
    }

    placePageSizer(widgets) {
      return this.renderWidget('pagesizer', widgets, PageSizer);
    }

    placeTableSummary(widgets) {
      return this.renderWidget('tablesummary', widgets, TableSummary);
    }
  };
  Table.initClass();
  return Table;
})());

