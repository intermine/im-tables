// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
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

const SuggestionSource = require('../utils/suggestion-source');
const Messages = require('../messages');
const AttributeValueControls = require('./attribute-value-controls');

const html = fs.readFileSync(__dirname + '/../templates/extra-value-controls.html', 'utf8');

const template = _.template(html);

module.exports = (LoopValueControls = class LoopValueControls extends AttributeValueControls {

  initialize() {
    super.initialize(...arguments); // sets query, branding, etc.
    this.state.set({extraPlaceholder: Messages.get('conbuilder.ExtraPlaceholder')});
    this.listenTo(this.branding, 'change:defaults.extraValue.path', this.reRender);
    this.listenTo(this.branding, 'change:defaults.extraValue.value', function() {
      return this.state.set({extraPlaceholder: this.branding.get('defaults.extraValue.value')});
    });
    // The following is fairly brutal, but it was the only way to get correct
    // rendering with type-aheads.
    return this.listenTo(this.model, 'change', this.reRender);
  }

  stateEvents() { return _.extend(super.stateEvents(...arguments),
    {'change:extraPlaceholder': this.reRender}); }

  template(data) {
    const base = super.template(...arguments);
    return base + template(data);
  }

  events() {
    return {
      'change .im-con-value-attr': 'setValue',
      'change .im-extra-value': 'setExtraValue'
    };
  }

  setExtraValue() {
    let input = this.$('input.im-extra-value.tt-input');
    if (!input.length) { input = this.$('input.im-extra-value'); }
    const value = input.val();
    if (value) {
      return this.model.set({extraValue: value});
    } else {
      return this.model.unset('extraValue');
    }
  }

  setValue() {
    let input = this.$('input.im-con-value.tt-input');
    if (!input.length) { input = this.$('input.im-con-value'); }
    const value = input.val();
    if (value) {
      return this.model.set({value});
    } else {
      return this.model.unset('value');
    }
  }

  setBoth() {
    this.setValue();
    return this.setExtraValue();
  }

  suggestExtra() {
    let suggestingExtra;
    const path = this.branding.get('defaults.extraValue.path');
    const target = this.branding.get('defaults.extraValue.extraFor');
    return suggestingExtra = (() => {
      if ((path == null) || !this.model.get('path').isa(target)) {
      return Promise.resolve(true);
    } else {
      const summPath = `${ this.model.get('path') }.${ path }`;
      const suggesting = (this.__extra_suggestions != null ? this.__extra_suggestions : (this.__extra_suggestions = this.query.summarise(summPath)));
      const handler = this.handleSuggestionSet.bind(this, this.$('input.im-extra-value'), 'extraValue');
      return suggesting.then(({results}) => results).then(handler);
    }
    })();
  }

  suggestValue() {
    const path = this.model.get('path');
    const s = this.query.service;
    const cls = path.getEndClass().name;
    const gettingKeys = s.fetchClassKeys().then(keys => keys[cls]);
    if (this.__value_suggestions == null) { this.__value_suggestions = gettingKeys.then(keys => {
      if (!(keys != null ? keys.length : undefined)) { return []; }
      const summaries = (Array.from(keys).map((k) => this.query.summarise(path + k.replace(/^[^\.]+/, ''))));
      return Promise.all(summaries).then(resultSets => resultSets.reduce(((acc, rs) => acc.concat(rs.results)), []));
  }); }
    const handler = this.handleSuggestionSet.bind(this, this.$('input.im-con-value-attr'), 'value');
    return this.__value_suggestions.then(handler);
  }

  handleSuggestionSet(input, prop, results) {
    const total = results.length;
    if (total === 0) { return; }
    const source = new SuggestionSource(results, total);
    const opts = {
      minLength: 0,
      highlight: true
    };
    const dataset = {
      name: `${ prop }_suggestions`,
      source: source.suggest,
      displayKey: 'item',
      templates: {
        footer: source.tooMany
      }
    };

    const handleSuggestion = control => (e, suggestion) => {
      return this.model.set(prop, suggestion.item);
    };
    const mostCommon = results[0].item;

    return this.activateTypeahead(input, opts, dataset, mostCommon, (handleSuggestion(input)), () => this.setBoth());
  }

  provideSuggestions() {
    this.removeTypeAheads();
    const suggestingValue = this.suggestValue();
    const suggestingExtra = this.suggestExtra();
    return Promise.all([suggestingExtra, suggestingValue]);
  }

  remove() {
    super.remove(...arguments);
    return this.branding.destroy();
  }
});
