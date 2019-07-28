// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let Cell;
const _ = require('underscore');
const $ = require('jquery');

const CoreView = require('../../core-view');
const Templates = require('../../templates');
const Options = require('../../options');
const Messages = require('../../messages');
const CellModel = require('../../models/cell');
const Formatting = require('../../formatting');

Messages.setWithPrefix('table.cell', {
  Link: 'link',
  NullEntity: 'No <%= type %>',
  PreviewTitle({types}) {
    return types.join(Options.get('DynamicObjects.NameDelimiter'));
  }
}
);

const SelectedObjects = require('../../models/selected-objects');
const types = require('../../core/type-assertions');

const popoverTemplate = Templates.template('classy-popover')({classes: 'item-preview'});

// Null safe isa test. Tests if the path is an instance of the
// given type, eg: PathInfo(Department.employees) isa 'Employee' => true
// :: (PathInfo, String) -> boolean
const _compatible = function(path, ct) {
  if (ct != null) { return (path.model.findSharedAncestor(path, ct) != null); } else { return false; }
};

// We memoize this to avoid re-walking the inheritance heirarchy, and because
// we know a-priori that the same call will be repeated many times in the same
// table for each change in common type (eg. in a table of 50 rows, which
// has one Department column, two Employee columns and one Manager column (ie. a very
// small table), then a change in the common type will results in 50x4 = 200
// examinations of the common type, all of which are one of four calls, either
// Department < CT, Employee < CT, CEO < CT or Manager < CT).
//
// eg. In a worst case scenario like the call `(compatible Enhancer, BioEntity)`, for
// each enhancer in the table we would have to examine each of the 5 types in
// the inheritance heirarchy between Enhancer and BioEntity.
//
// The key for the memoization is the concatenation of the queried type and the
// given common type. We replace null common types with '!' since that is not a
// legal class name, and thus guaranteed not to collide with valid types.
//
// :: (PathInfo, String) -> boolean
const compatible = _.memoize(_compatible, (p, ct) => `${ p }<${ ct != null ? ct : '!' }`);

// A Cell representing a single attribute value.
// Forms a pair with ./subtable
module.exports = (Cell = (function() {
  Cell = class Cell extends CoreView {
    static initClass() {
  
      this.prototype.Model = CellModel;
  
      // This is a table cell.
      this.prototype.tagName = 'td';
  
      // Identifying class name.
      this.prototype.className = 'im-result-field';
  
      // A function that when called returns an HTML string suitable
      // for direct inclusion. The default formatter is very simple
      // and just returns the escaped value.
      //
      // Note that while a property of this class, this function
      // is called in such a way that it never has access to the this
      // reference.
      this.prototype.formatter = Formatting.defaultFormatter;
  
      // Initialization
  
      this.prototype.parameters = [
        'model',           // We need a cell model to function.
        'service',         // We pass the service on to some child elements.
        'selectedObjects', // the set of selected objects.
        'tableState',      // provides {selecting, previewOwner, highlitNode}
        'popovers'         // creates popovers
      ];
  
      this.prototype.optionalParameters = ['formatter'];
  
      this.prototype.parameterTypes = {
        model: (new types.InstanceOf(CellModel, 'models/cell')),
        selectedObjects: (new types.InstanceOf(SelectedObjects, 'SelectedObjects')),
        formatter: types.Callable,
        tableState: types.Model,
        service: types.Service,
        popovers: (new types.Structure('HasGet', {get: types.Function}))
      };
  
      // Rendering logic.
  
      this.prototype.template = Templates.template('table-cell');
  
      this.prototype.popoverTarget = null;
    }

    // Scoped unique element id.
    id() { return _.uniqueId('im_table_cell_'); }

    initialize() {
      super.initialize(...arguments);
      return this.listen();
    }

    initState() {
      this.setSelected();
      this.setSelectable();
      this.setHighlit();
      return this.setMinimised();
    }

    // getPath is part of the RowCell API
    // :: -> PathInfo
    getPath() { return this.model.get('column'); }

    // Return the Path representing the query node of this column.
    // :: -> PathInfo
    getTypes() {
      const node = this.model.get('node');
      const classes = this.model.get('entity').get('classes');
      if (classes != null) { return (Array.from(classes).map((c) => node.model.makePath(c))); } else { return [node]; }
    }

    // Event wiring:

    listen() {
      this.listenToEntity();
      this.listenToSelectedObjects();
      this.listenToOptions();
      return this.listenToTableState();
    }

    listenToOptions() { // these events are expected to be rare.
      this.listenTo(Options, 'change:TableCell.IndicateOffHostLinks', this.reRender);
      this.listenTo(Options, 'change:TableCell.ExternalLinkIcons', this.reRender);
      return this.listenTo(Options, 'change:TableCell.PreviewTrigger', this.onChangeTrigger);
    }

    listenToTableState() { // these events deal with co-ordination with global table state.
      const ts = this.tableState;
      this.listenTo(ts, 'change:selecting',    this.setInputDisplay);
      this.listenTo(ts, 'change:previewOwner', this.closeOwnPreview);
      this.listenTo(ts, 'change:highlitNode',  this.setHighlit);
      return this.listenTo(ts, 'change:minimisedColumns', this.setMinimised);
    }

    // We listen to find out if the user selected us by clicking on another related cell.
    listenToSelectedObjects() {
      const objs = this.selectedObjects;
      this.listenTo(objs, 'add remove reset',                   this.setSelected);
      return this.listenTo(objs, 'add remove reset change:commonType change:node', this.setSelectable);
    }

    modelEvents() { // The model for a cell is pretty static.
      return {'change:entity': this.onChangeEntity}; // make sure we unbind if it changes.
    }

    stateEvents() { // these events cause DOM twiddling.
      return {
        'change:highlit change:selected': this.setActiveClass,
        'change:selectable': this.onChangeSelectable,
        'change:selected': this.setInputChecked,
        'change:showPreview': this.onChangeShowPreview,
        'change:minimised': this.reRender // nothing for it - full re-render is required.
      };
    }

    events() { // the specific DOM event set depends on the configured click behaviour.
      const events = {
        'show.bs.popover': this.onShowPreview,
        'hide.bs.popover': this.onHidePreview,
        'click a.im-cell-link': this.onClickCellLink
      };

      const opts = Options.get('TableCell');
      const trigger = opts.PreviewTrigger;
      if (trigger === 'hover') {
        events['mouseover .im-cell-link'] = this.showPreview;
        events['mouseout .im-cell-link'] = this.hidePreview;
        events['click'] = this.activateChooser;
      } else if (trigger === 'click') {
        events['click'] = this.clickTogglePreview;
      } else {
        throw new Error(`Unknown cell preview: ${ trigger}`);
      }

      return events;
    }

    // Event listeners.

    onChangeTrigger() {
      this.destroyPreview();
      this.initPreview();
      return this.delegateEvents();
    }

    // The purpose of this handler is to propagate an event up the DOM
    // so that higher level listeners can capture it and possibly prevent
    // the page navigation (by e.preventDefault()) if they choose to do
    // something else.
    onClickCellLink(e) {
      // When selecting, it just acts to select.
      if (this.tableState.get('selecting')) {
        e.preventDefault();
        return;
      }

      // Allow the table to handle this event, if it so chooses
      // attach the entity for handlers to inspect.
      const viewEvent = $.Event('view.im.object');
      viewEvent.object = this.model.get('entity').toJSON();
      this.$el.trigger(viewEvent);
      if (viewEvent.isDefaultPrevented()) {
        return e.preventDefault();
      }
    }

    // Close our preview if another cell has opened theirs
    closeOwnPreview() {
      const myId = this.el.id;
      const currentOwner = this.tableState.get('previewOwner');
      if (myId !== currentOwner) {
        this.hidePreview();
        // In some cases the preview is getting stuck on the screen.
        // With the preview present, and the showPreview state set
        // to false, an event never fires to remove the own popup.
        // Force it for now.
        return this._hidePreview();
      }
    }

    // Listen to the entity that backs this cell, updating the value if it
    // changes. This is important for cell formatters so that they can
    // request new information in a uniform manner.
    listenToEntity() {
      return this.listenTo((this.model.get('entity')), 'change', this.updateValue);
    }

    // Event handlers.

    onShowPreview() { return this.tableState.set({previewOwner: this.el.id}); }

    onHidePreview() { // make sure we disclaim ownership.
      const myId = this.el.id;
      const currentOwner = this.tableState.get('previewOwner');
      if (myId === currentOwner) { return this.tableState.set({previewOwner: null}); }
    }

    // This method is complicated because each object can have multiple
    // identities if it is a dynamic object. An Employee/Bibliophile can
    // only be added to the selection as an Employee or as a Bibliophile,
    // and this method must decide which of these personalities is used.
    toggleSelection() {
      let found;
      const ent = this.model.get('entity');
      const id = ent.get('id');
      if (ent == null) { return; }

      if (found = this.selectedObjects.get(id)) {
        return this.selectedObjects.remove(found); // We were there - remove us.
      } else {
        const toAdd = this.getMostSuitableIdentity();

        if (toAdd == null) {
          throw new Error("None of our identities is a compatible");
        }

        return this.selectedObjects.add(toAdd);
      }
    }

    getMostSuitableIdentity() {
      const node = this.model.get('node');
      const columnTypes = node.model.getSubclassesOf(node.getType());
      const id = this.model.get('entity').get('id');
      const identities = (Array.from(this.getTypes()).map((t) => ({'class': String(t), id})));

      // If we can add anything, add the identity of ours which matches the node.
      if (this.selectedObjects.isEmpty()) {
        return _.find(identities, x => Array.from(columnTypes).includes(x['class']));
      } else {
        const ct = node.model.makePath(this.selectedObjects.state.get('commonType'));
        const suitable = _.all(identities, x => compatible(ct, x['class']));
        const ranked = _.sortBy(identities, x => // Most specific last
          node.model.getAncestorsOf(x['class']).length
        );
        return _.last(ranked);
      }
    }

    setSelected() { return this.state.set({'selected': (this.selectedObjects.get(this.model.get('entity')) != null)}); }

    setSelectable() {
      const commonType = this.selectedObjects.state.get('commonType');
      const node = this.selectedObjects.state.get('node');
      const size = this.selectedObjects.size();
      // Selectable when nothing is selected or it is of the right type.
      const selectable = (((node == null)) || (node === String(this.model.get('node')))) && 
                   ((size === 0) || (this.isCompatibleWith(commonType)));
      return this.state.set({selectable});
    }

    isCompatibleWith(commonType) {
      return this.getTypes().some(t => compatible(t, commonType));
    }

    setHighlit() {
      const myNode = this.model.get('node');
      const highlit = this.tableState.get('highlitNode');
      return this.state.set({highlit: ((highlit != null) && (String(myNode) === String(highlit)))});
    }

    setMinimised() {
      const myColumn = this.model.get('column');
      const minimised = this.tableState.get('minimisedColumns').contains(myColumn);
      return this.state.set({minimised});
    }

    onChangeEntity() {
      // Should literally never happen - we should probably throw an error.
      const prev = this.model.previous('entity');
      delete this._has_id;
      if (prev != null) { this.stopListening(prev); }
      return this.listenToEntity();
    }

    clickTogglePreview() { // click handler when the preview trigger is 'click'
      return this.activateChooser() || this.state.toggle('showPreview');
    }

    activateChooser() { // click handler when the preview trigger is 'hover'
      // can only select things with ids.
      if (!this.hasID()) { return; }
      const selecting = this.tableState.get('selecting');
      const selectable = this.state.get('selectable');
      if (selectable && selecting) { // then toggle state of 'selected'
        return this.toggleSelection();
      }
    }

    // Cachable query of the entity.
    hasID() { return this._has_id != null ? this._has_id : (this._has_id = (this.model.get('entity').get('id') != null)); }

    showPreview() { return this.state.set({showPreview: true}); }
    hidePreview() { return this.state.set({showPreview: false}); }

    _showPreview() { if (this.rendered) {
      if (this.tableState.get('selecting')) { return; } // don't show previews when selecting.
      const opts = Options.get('TableCell');
      const show = () => {
        // We test here too since it may have been hidden during the hover delay.
        if (this.state.get('showPreview')) { return (this.children.popover != null ? this.children.popover.render() : undefined); }
      };
      if (opts.PreviewTrigger === 'hover') {
        return _.delay(show, opts.HoverDelay);
      } else {
        return show();
      }
    } }

    _hidePreview() {
      if (this.children.popover != null ? this.children.popover.rendered : undefined) {
        return (this.popoverTarget != null ? this.popoverTarget.popover('hide') : undefined);
      }
    }

    onChangeShowPreview() {
      if (this.state.get('showPreview')) {
        return this._showPreview();
      } else {
        return this._hidePreview();
      }
    }

    onChangeSelectable() {
      this.setDisabledCellClass();
      return this.setInputDisabled();
    }

    // Rather than full re-renders, which would get expensive for many cells,
    // we just reach in and twiddle these specific DOM attributes:

    updateValue() { return _.defer(() => {
      return this.$('.im-displayed-value').html(this.getFormattedValue());
    }); }

    setActiveClass() {
      const {highlit, selected} = this.state.pick('highlit', 'selected');
      return this.$el.toggleClass('active', (highlit || selected));
    }

    setInputChecked() {
      return this.$('input').prop({checked: this.getInputState().checked});
    }

    setInputDisplay() {
      return this.$('input').css({display: this.getInputState().display});
    }

    setDisabledCellClass() {
      return this.$el.toggleClass('im-not-selectable', (!this.state.get('selectable')));
    }

    setInputDisabled() {
      return this.$('input').prop({disabled: this.getInputState().disabled});
    }

    getData() {
      let reportUri;
      const opts = Options.get('TableCell');
      const host = opts.IndicateOffHostLinks ? global.location.host : /.*/;

      const data = this.model.toJSON();
      data.formattedValue = this.getFormattedValue();
      data.input = this.getInputState();
      data.icon = null;
      data.url = (reportUri = data.entity['report:uri']);
      data.isForeign = (reportUri && !reportUri.match(host));
      data.target = data.isForeign ? '_blank' : '';
      data.NULL_VALUE = Templates.null_value;

      for (let domain in opts.ExternalLinkIcons) {
        const url = opts.ExternalLinkIcons[domain];
        if ((reportUri != null ? reportUri.match(domain) : undefined)) {
          if (data.icon == null) { data.icon = url; }
        }
      }

      return _.extend(this.getBaseData(), data);
    }

    // The mechanism by which we apply the formatter the cell.
    // We call the foratter with the entity, its service and the raw value.
    // We use call with this set to null so that we don't leak the API of
    // this class to the formatters.
    //
    // If the value is null, then we always return null.
    getFormattedValue() {
      const {entity, value} = this.model.pick('entity', 'value');
      if (value != null) { return this.formatter.call(null, entity, this.service, value); } else { return null; }
    }

    // Special get data method just for the input.
    // which is probably a good indication it should be its own view.
    getInputState() {
      const selecting = this.tableState.get('selecting');
      const {selected, selectable} = this.state.pick('selected', 'selectable');
      const checked = selected;
      const disabled = !selectable;
      const display = selecting ? 'inline' : 'none';
      return {checked, disabled, display};
    }

    // InterMine objects (i.e. objects with ids) can have previews.
    // We find the preview information using `Query::findById` and
    // queries that use the `id` property, so this is a requirement.
    canHavePreview() { return this.hasID() && (!this.state.get('minimised')); }

    // Make sure this element has the correct classes, and initialise the preview popover.
    postRender() {
      this.setAttrClass();
      this.setActiveClass();
      this.setMinimisedClass();
      this.setDisabledCellClass();
      this.setFormatterClasses();
      return this.initPreview();
    }

    setAttrClass() { if (Options.get('TableCell.AddDataClasses')) {
      const attrType = this.model.get('column').getType();
      this.$el.addClass(`im-type-${attrType.toLowerCase()}`);
      for (let entType of Array.from(this.getTypes())) {
        this.$el.addClass(String(entType));
      }
      return this.$el.addClass(this.model.get('column').end.name);
    } }

    setMinimisedClass() { return this.$el.toggleClass('im-minimised', this.state.get('minimised')); }

    setFormatterClasses() {
      const cls = this.formatter.classes;
      if (cls != null) { this.$el.addClass(cls); }
      const { target } = this.formatter;
      if (target != null) { return this.$el.addClass(target); }
    }

    // Code associated with the preview.

    getPreviewContainer() {
      let con = [];
      // we are bound to find one of these
      const candidates = ['.im-query-results', '.im-table-container', '.panel', 'table', 'body'];
      while (candidates.length && (con.length === 0)) {
        con = this.$el.closest(candidates.shift());
      }
      return con;
    }

    removeAllChildren() {
      this.destroyPreview();
      if (this.children.popover != null) {
        this.stopListeningTo(this.children.popover);
        if (this.children.popover.rendered) { this.$el.popover('destroy'); }
      }
      return super.removeAllChildren(...arguments);
    }

    destroyPreview() { if (this.children.popover != null) {
      this.stopListeningTo(this.children.popover);
      if (this.children.popover.rendered) { if (this.popoverTarget != null) {
        this.popoverTarget.popover('destroy');
      } }
      delete this.popoverTarget;
      return this.removeChild('popover');
    } }

    initPreview() {
      if ((this.children.popover != null) || (!this.canHavePreview())) { return; }
      // Create the popover now, but no data will be fetched until render is called.
      const content = this.popovers.get(this.model.get('entity'));
      const trigger = Options.get('TableCell.PreviewTrigger');
      this.popoverTarget = trigger === 'hover' ? this.$('.im-cell-link') : this.$el;
      const getTitle = Messages.getText.bind(Messages, 'table.cell.PreviewTitle');

      this.listenToOnce(content, 'rendered', () => {
        const container = this.getPreviewContainer();
        return this.popoverTarget.popover({
          trigger: 'manual',
          template: popoverTemplate,
          placement: 'auto left',
          container,
          html: true, // well, technically we are using Elements.
          title: () => getTitle({types: this.model.get('typeNames')}), // see CellModel
          content: content.el
        });
      });

      // This is how we actually trigger the popover, hence it
      // is imporant to call re-render on the preview when we want
      // to show it inside the popover - see `::showPreview()`
      this.listenTo(content, 'rendered', () => this.popoverTarget.popover('show'));
      return this.children.popover = content;
    }
  };
  Cell.initClass();
  return Cell;
})());
