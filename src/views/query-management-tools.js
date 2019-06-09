/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let QueryManagement, Types;
const CoreView = require('../core-view');
const {UnionOf, Listenable, Structure} = (Types = require('../core/type-assertions'));

const ColumnMangerButton   = require('./column-manager/button');
const FilterDialogueButton = require('./filter-dialogue/button');
const JoinManagerButton    = require('./join-manager/button');

const HistoryType = UnionOf(Listenable, new Structure('History',
  {getCurrentQuery: Types.Function})
);

module.exports = (QueryManagement = (function() {
  QueryManagement = class QueryManagement extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-query-management';
  
      this.prototype.parameters = ['history'];
  
      this.prototype.parameterTypes =
        {history: HistoryType};
    }

    initialize() {
      super.initialize(...arguments);
      return this.listenTo(this.history, 'changed:current', this.reRender);
    }

    renderChildren() {
      const query = this.history.getCurrentQuery();
      this.renderChild('cols', (new ColumnMangerButton({query})));
      this.renderChild('cons', (new FilterDialogueButton({query})));
      return this.renderChild('joins', (new JoinManagerButton({query})));
    }
  };
  QueryManagement.initClass();
  return QueryManagement;
})());


