/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ExportDialogueButton;
const _ = require('underscore');

// Base class.
const QueryDialogueButton = require('../query-dialogue-button');

// The model for this class.
const ExportDialogue = require('../export-dialogue');

const Counter = require('../../utils/count-executor');

module.exports = (ExportDialogueButton = (function() {
  ExportDialogueButton = class ExportDialogueButton extends QueryDialogueButton {
    static initClass() {
  
      // an identifying class.
      this.prototype.className = 'im-export-dialogue-button';
  
      this.prototype.longLabel = 'export.ExportQuery';
      this.prototype.shortLabel = 'export.Export';
      this.prototype.icon = 'Download';
  
      this.prototype.optionalParameters = ['tableState'];
  
      this.prototype.Dialogue = ExportDialogue;
  }

    initialize() {
      super.initialize(...arguments);
      return Counter.count(this.query) // Disable export if no results or in error.
             .then(count => this.state.set({disabled: count === 0}))
             .then(null, err => this.state.set({disabled: true, error: err}));
  }

    initState() {
      return this.state.set({name: this.query.name});
  }

    dialogueOptions() {
      const page = this.tableState != null ? this.tableState.pick('start', 'size') : undefined;
      return {query: this.query, model: {tablePage: page}};
  }
};
  ExportDialogueButton.initClass();
  return ExportDialogueButton;
})());
