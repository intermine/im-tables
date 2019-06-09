/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('underscore');

const Model = require('./core-model');

const Options = require('./options');

const ICONS = {};

const registerIconSet = (name, icons) => ICONS[name] = _.extend({}, icons);

class Icons extends Model {

  icon(key, size, props) {
    if (props == null) { props = {}; }
    const classes = [];
    const ps = ((() => {
      const result = [];
      for (let prop in props) {
        const propVal = props[prop];
        if (prop !== 'className') {
          result.push(`${ prop }=\"${ _.escape(propVal) }\"`);
        }
      }
      return result;
    })());
    if ('className' in props) { classes.push( _.escape(props.className) ); }
    classes.push(this.iconClasses(key));
    if (size) { classes.push(this.getSize(size)); }
    return `<i class="${ classes.join(' ') }" ${ ps.join(' ') }></i>`;
  }

  iconWithProps(key, props) { return this.icon(key, null, props); }

  getSize(size) { let left;
  return (left = this.get(`size${ size.toUpperCase() }`)) != null ? left : ''; }

  iconClasses(key) { return `${ this.get('Base') } ${ this.get(key) }`; }

  _loadIconSet() {
    let iconSet;
    if (iconSet = ICONS[this.options.get('icons')]) {
      this.clear({silent: true});
      if (iconSet != null) { return this.set(iconSet); }
    }
  }

  initialize(options) {
    if (options == null) { options = Options; }
    this.options = options;
    this._loadIconSet();
    return this.listenTo(this.options, 'change:icons', this._loadIconSet);
  }
}

ICONS.glyphicons = {
  Base: 'glyphicon',
  unsorted: "glyphicon-resize-vertical",
  ASC: "glyphicon-arrow-up",
  DESC: "glyphicon-arrow-down",
  headerIcon: "icon",
  headerIconRemove: "glyphicon-remove",
  headerIconHide: "glyphicon-minus",
  headerIconReveal: 'glyphicon-fullscreen',
  SortStringASC:   'glyphicon-sort-by-alphabet',
  SortStringDESC:  'glyphicon-sort-by-alphabet-alt',
  SortNumericASC:  'glyphicon-sort-by-order',
  SortNumericDESC: 'glyphicon-sort-by-order-alt',
  RootClass: 'glyphicon-stop',
  Yes: "glyphicon-star",
  No: "glyphicon-star-empty",
  Table: 'glyphicon-list',
  Script: "glyphicon-console",
  Export: "glyphicon-cloud-download",
  Error: "glyphicon-warning-sign",
  Info: 'glyphicon-info-sign',
  Warning: "glyphicon-warning-sign",
  Remove: "glyphicon-minus-sign",
  OK: "glyphicon-ok",
  Cancel: "glyphicon-remove",
  Check: "glyphicon-check",
  UnCheck: "glyphicon-unchecked",
  CheckUnCheck: "glyphicon-ok-none",
  Add: "glyphicon-plus-sign",
  Move: "glyphicon-move",
  More: "glyphicon-plus-sign",
  Filter: "glyphicon-filter",
  Summary: "glyphicon-stats",
  Undo: "glyphicon-refresh",
  Refresh: "glyphicon-refresh",
  Columns: "glyphicon-pause",
  Collapsed: "glyphicon-chevron-right",
  Expanded: "glyphicon-chevron-down",
  CollapsedSection: 'glyphicon-triangle-right',
  ExpandedSection: 'glyphicon-triangle-bottom',
  MoveDown: "glyphicon-chevron-down",
  GoBack: "glyphicon-chevron-left",
  GoForward: "glyphicon-chevron-right",
  MoveUp: "glyphicon-chevron-up",
  Toggle: "glyphicon-random",
  ExpandCollapse: "glyphicon-chevron-right icon-chevron-down",
  Help: "glyphicon-question-sign",
  ReverseRef: "glyphicon-retweet",
  Reorder: "glyphicon-menu-hamburger",
  Edit: 'glyphicon-edit',
  ExtraValue: 'glyphicon-map-marker',
  Tree: 'glyphicon-plus',
  Download: 'glyphicon-save-file',
  download: 'glyphicon-cloud-download',
  Options: 'glyphicon-tasks',
  ClipBoard: 'glyphicon-paperclip',
  Composed: 'glyphicon-tags',
  RemoveConstraint: 'glyphicon-remove-sign',
  Dismiss: 'glyphicon-remove-sign',
  ClosedReference: 'glyphicon-expand',
  OpenReference: 'glyphicon-collapse-down',
  Lock: 'glyphicon-lock',
  Lists: 'glyphicon-list-alt',
  Attribute: "glyphicon-unchecked",
  ExternalLink: 'glyphicon-globe',
  tsv: 'glyphicon-list',
  csv: 'glyphicon-list',
  xml: 'glyphicon-xml',
  json: 'glyphicon-json',
  fake: 'glyphicon-bug',
  Bug: 'glyphicon-bug',
  Rubbish: 'glyphicon-trash',
  RubbishFull: 'glyphicon-trash',
  Joins: 'glyphicon-link',
  Mail: 'glyphicon-envelope'
};

ICONS.fontawesome = {
  Base: 'fa',
  unsorted: "fa-unsorted",
  ASC: "fa-sort-up",
  DESC: "fa-sort-down",
  SortStringASC: 'fa-sort-alpha-asc',
  SortStringDESC: 'fa-sort-alpha-desc',
  SortNumericASC: 'fa-sort-numeric-asc',
  SortNumericDESC: 'fa-sort-numeric-desc',
  headerIcon: "fa",
  headerIconRemove: "fa-times",
  headerIconHide: "fa-ellipsis-h",
  headerIconReveal: 'fa-arrows-h',
  sizeLG: 'fa-2x',
  Yes: "fa-star",
  No: "fa-star-o",
  Table: 'fa-list',
  EmptyTable: 'fa-table',
  Script: "fa-file-code-o",
  Export: "fa-cloud-download",
  Remove: "fa-minus-circle",
  OK: "fa-check",
  Cancel: "fa-remove",
  Check: "fa-toggle-on",
  UnCheck: "fa-toggle-off",
  CheckUnCheck: "fa-toggle-on fa-toggle-off",
  Add: "fa-plus",
  Move: "fa-arrows",
  More: "fa-plus",
  Dropbox: 'fa-dropbox',
  Drive: 'fa-google',
  download: 'fa-cloud-download',
  Galaxy: 'fa-cloud-upload',
  GenomeSpace: 'fa-cloud-upload',
  Filter: "fa-filter",
  Summary: "fa-bar-chart-o",
  Undo: "fa-undo",
  Refresh: "fa-refresh",
  Columns: "fa-columns",
  Collapsed: "fa-chevron-right",
  Expanded: "fa-chevron-down",
  CollapsedSection: 'fa-caret-right',
  ExpandedSection: 'fa-caret-down',
  MoveDown: "fa-chevron-down",
  GoBack: "fa-chevron-left",
  GoForward: "fa-chevron-right",
  MoveUp: "fa-chevron-up",
  Toggle: "fa-retweet",
  ExpandCollapse: "fa-chevron-right fa-chevron-down",
  Help: "fa-question-circle",
  Tree: 'fa-sitemap',
  ReverseRef: 'fa-retweet',
  Reorder: "fa-reorder",
  Options: 'fa-tasks',
  Edit: 'fa-edit',
  ExtraValue: 'fa-database',
  Download: 'fa-file-archive-o',
  ClipBoard: 'fa-paperclip',
  Composed: 'fa-tags',
  RemoveConstraint: 'fa-times-circle',
  Dismiss: 'fa-times-circle',
  Error: 'fa-warning',
  Info: 'fa-info-circle',
  Warning: 'fa-warning',
  Lock: 'fa-lock',
  RootClass: 'fa-square',
  Attribute: 'fa-tag',
  ClosedReference: 'fa-plus-square',
  OpenReference: 'fa-plus-square-o',
  CodeFile: 'fa-file-code-o',
  Rubbish: 'fa-trash-o',
  RubbishFull: 'fa-trash',
  Joins: 'fa-share-alt',
  ExternalLink: 'fa-globe',
  Lists: 'fa-cloud-upload',
  tsv: 'fa-file-excel-o',
  csv: 'fa-file-excel-o',
  xml: 'fa-code',
  json: 'fa-json',
  fake: 'fa-bug',
  Bug: 'fa-bug',
  Mail: 'fa-envelope'
};

module.exports = new Icons;
module.exports.Icons = Icons; // Export constructor on default instance.
module.exports.registerIconSet = registerIconSet;

// Get all registered icon names.
module.exports.names = function() {
  const listsOfNames = ((() => {
    const result = [];
    for (let n in ICONS) {
      const s = ICONS[n];
      result.push(_.keys(s));
    }
    return result;
  })());
  return _.union.apply(null, listsOfNames);
};
