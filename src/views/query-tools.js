/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let QueryTools;
const _ = require('underscore');
const $ = require('jquery');

const CoreView = require('../core-view');
const Templates = require('../templates');
const Options = require('../options');

const QueryManagement      = require('./query-management-tools');
const UndoHistory          = require('./undo-history');
const ListDialogueButton   = require('./list-dialogue/button');
const CodeGenButton        = require('./code-gen-button');
const ExportDialogueButton = require('./export-dialogue/button');
const {Bus}                = require('../utils/events');

const SUBSECTIONS = ['im-query-management', 'im-history', 'im-query-consumers'];

const subsection = s => `<div class="${ s } clearfix"></div>`;

module.exports = (QueryTools = (function() {
  QueryTools = class QueryTools extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-query-tools';
  
      this.prototype.parameters = ['tableState', 'history', 'selectedObjects'];
  
      this.prototype.optionalParameters = [
        'bus', // An event bus
        'consumerContainer',
        'consumerBtnClass'
      ];
  
      this.prototype.bus = (new Bus);
    }

    template() { return (SUBSECTIONS.map(subsection)).join(''); }

    initialize() {
      super.initialize(...arguments);
      return this.listenTo(this.history, 'changed:current', this.renderQueryConsumers);
    }

    renderChildren() {
      this.renderManagementTools();
      this.renderUndo();
      return this.renderQueryConsumers();
    }

    renderManagementTools() {
      return this.renderChildAt('.im-query-management', new QueryManagement({history: this.history}));
    }

    renderUndo() {
      const $undo = this.$('.im-history');
      return this.renderChild('undo', (new UndoHistory({collection: this.history})), $undo);
    }

    getConsumerContainer() {
      if (this.consumerContainer != null) {
        this.consumerContainer.classList.add(Options.get('StylePrefix'));
        this.consumerContainer.classList.add('im-query-consumers');
        this.$('.im-query-management').addClass('im-has-more-space');
        this.$('.im-history').addClass('im-has-more-space');
        return this.consumerContainer;
      } else {
        const cons = this.$('.im-query-consumers').empty();
        if (cons.length) { return cons; }
      }
    }

    renderQueryConsumers() {
      const container = this.getConsumerContainer();
      if (!container) { return; } // No point instantiating children that won't appear.
      const query = this.history.getCurrentQuery();
      const selected = this.selectedObjects;
      const listDialogue = new ListDialogueButton({query, tableState: this.tableState, selected});
      this.listenTo(listDialogue, 'all', (evt, ...args) => {
        this.bus.trigger(`list-action:${evt}`, ...Array.from(args));
        return this.bus.trigger("list-action", evt, ...Array.from(args));
      });

      this.renderChild('save', (new ExportDialogueButton({query, tableState: this.tableState})), container);
      this.renderChild('code', (new CodeGenButton({query, tableState: this.tableState})), container);
      this.renderChild('lists', listDialogue, container);

      if (this.consumerContainer && this.consumerBtnClass) {
        for (let kid of ['save', 'code', 'lists']) {
          this.listenTo(this.children[kid], 'rendered', this.setButtonStyle);
        }
      }

      return this.setButtonStyle();
    }

    setButtonStyle() {
      let cls, con;
      if ((con = this.consumerContainer) && (cls = this.consumerBtnClass)) {
        return $('.btn', con).addClass(cls);
      }
    }
  };
  QueryTools.initClass();
  return QueryTools;
})());

