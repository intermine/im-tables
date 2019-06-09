/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let LoopValueControls;
const _ = require('underscore');
const fs = require('fs');
const {Promise} = require('es6-promise');

const Messages = require('../messages');
const View = require('../core-view');

const helpers = require('../templates/helpers');
const mustacheSettings = require('../templates/mustache-settings');
const toNamedPath = require('../utils/to-named-path');

const html = fs.readFileSync(__dirname + '/../templates/loop-value-controls.html', 'utf8');
const template = _.template(html);

const toOption = ({path, name}) => ({value: path.toString(), text: name});

module.exports = (LoopValueControls = class LoopValueControls extends View {

  initialize({query}) {
    this.query = query;
    super.initialize(...arguments);
    this.path = this.model.get('path');
    this.type = this.path.getType();
    this.setCandidateLoops();
    return this.listenTo(this.model, 'change', this.reRender);
  }

  events() {
    return {'change select': 'setLoop'};
  }

  setLoop() { return this.model.set({value: this.$('select').val()}); }

  setCandidateLoops() { if (!this.model.has('candidateLoops')) {
    return this.getCandidateLoops().then(candidateLoops => this.model.set({candidateLoops}));
  } }

  isSuitable(candidate) {
    return ((candidate.isa(this.type)) || (this.path.isa(candidate.getType()))) &&
      (this.path.toString() !== candidate.toString());
  }

  // Cache this result, since we don't want to keep fetching display names.
  getCandidateLoops() { return this.__candidate_loops != null ? this.__candidate_loops : (this.__candidate_loops = (() => {
    const loopCandidates = ((() => {
      const result = [];
      for (let n of Array.from(this.query.getQueryNodes())) {         if (this.isSuitable(n)) {
          result.push(n);
        }
      }
      return result;
    })());

    return Promise.all(loopCandidates.map(toNamedPath));
  })()); }

  template(data) {
    return template(_.extend({messages: Messages}, helpers, data));
  }

  getData() {
    const currentValue = this.model.get('value');
    const candidateLoops = ((Array.from(this.model.get('candidateLoops') || [])).map((c) => toOption(c)));
    const isSelected = opt => opt.value === currentValue;
    return {candidateLoops, isSelected};
  }
});


