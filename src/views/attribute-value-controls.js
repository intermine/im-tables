// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS204: Change includes calls to have a more natural evaluation order
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let AttributeValueControls;
const $ = require('jquery');
const _ = require('underscore');
const {Promise} = require('es6-promise');

const Messages = require('../messages');
const Templates = require('../templates');
const CoreView = require('../core-view');
const Options = require('../options');
const NestedModel = require('../core/nested-model');
const getBranding = require('../utils/branding');
const {IS_BLANK} = require('../patterns');
const HasTypeaheads = require('../mixins/has-typeaheads');

const SuggestionSource = require('../utils/suggestion-source');

const {Model: {INTEGRAL_TYPES, NUMERIC_TYPES}, Query} = require('imjs');

const selectTemplate = Templates.template('attribute_value_select');

const trim = s => String(s).replace(/^\s+/, '').replace(/\s+$/, '');

const numify = x => 1 * trim(x);

const {numToString} = require('../templates/helpers');

Messages.set({
  'constraintvalue.NoValues': 'There are no possible values. This query returns no results',
  'constraintvalue.OneValue': `\
There is only one possible value: <%- value %>. You might want to remove this constraint\
`
});

module.exports = (AttributeValueControls = (function() {
  AttributeValueControls = class AttributeValueControls extends CoreView {
    static initClass() {
    
      this.include(HasTypeaheads);
  
      this.prototype.className = 'im-attribute-value-controls';
  
      this.prototype.template = Templates.template('attribute_value_controls');
      this.prototype.clearer = '<div class="" style="clear:both;">';
  
      this.prototype.makeSlider = (Templates.template('slider', {variable: 'markers'}));
    }

    getData() { return _.extend(this.getBaseData(), {messages: Messages, con: this.model.toJSON()}); }

    // @Override
    initialize({query}) {
      let needle;
      this.query = query;
      super.initialize(...arguments);
      this.sliders = [];
      this.branding = new NestedModel;
      this.cast = (needle = this.model.get('path').getType(), Array.from(NUMERIC_TYPES).includes(needle)) ? numify : trim;
      // Declare rendering dependency on messages
      this.listenTo(Messages, 'change', this.reRender);
      this.state.set({valuePlaceholder: Messages.getText('conbuilder.ValuePlaceholder')});
      this.listenTo(this.branding, 'change:defaults.value', function() {
        return this.state.set({valuePlaceholder: this.branding.get('defaults.value')});
      });
      if (this.query != null) {
        this.listenTo(this.query, 'change:constraints', this.clearCachedData);
        this.listenTo(this.query, 'change:constraints', this.reRender);
        return getBranding(this.query.service).then(branding => this.branding.set(branding));
      }
    }

    modelEvents() {
      return {
        destroy() { return this.stopListening(); }, // If the model is gone, then shut up and wait to be removed.
        'change:value': this.onChangeValue,
        'change:op': this.onChangeOp
      };
    }

    stateEvents() {
      return {'change:valuePlaceholder': this.reRender};
    }

    // Help translate between multi-value and =
    onChangeOp() {
      const newOp = this.model.get('op');
      if ((this.model.get('value') != null) && Array.from(Query.MULTIVALUE_OPS).includes(newOp)) {
        this.model.set({value: null, values: [this.model.get('value')]});
      }
      return this.reRender();
    }

    onChangeValue() { return this.reRender(); }

    removeAllChildren() {
      this.removeTypeAheads();
      this.removeSliders();
      return super.removeAllChildren(...arguments);
    }

    removeSliders() {
      return (() => {
        let sl;
        const result = [];
        while ((sl = this.sliders.pop())) {
          try {
            sl.slider('destroy');
            result.push(sl.remove());
          } catch (error) {}
        }
        return result;
      })();
    }

    events() {
      return {'change .im-con-value-attr': 'setAttributeValue'};
    }

    updateInput() {
      let left;
      const input = ((left = this.lastTypeahead()) != null ? left : this.$('.im-con-value-attr'));
      return input.val(this.model.get('value'));
    }

    readAttrValue() {
      let left;
      const raw = ((left = this.lastTypeahead()) != null ? left : this.$('.im-con-value-attr')).val();
      try {
        //  to string or number, as per path type
        if ((raw != null) && !IS_BLANK.test(raw)) { return this.cast(raw); } else { return null; }
      } catch (e) {
        this.model.set({error: new Error(`${ raw } might not be a legal value for ${ this.path }`)});
        return raw;
      }
    }

    setAttributeValue() { return this.model.set({value: this.readAttrValue()}); }

    postRender() {
      this.provideSuggestions().then(null, error => this.model.set({error}));
      return this.$('.im-con-value-attr').focus();
    }

    provideSuggestions() { return this.getSuggestions().then(({stats, results}) => {
      let msg;
      if (stats.uniqueValues === 0) {
        msg = Messages.getText('constraintvalue.NoValues');
        return this.model.set({error: {message: msg, level: 'warning'}});
      } else if (stats.uniqueValues === 1) {
        msg = Messages.getText('constraintvalue.OneValue', {value: results[0].item});
        return this.model.set({error: {message: msg, level: 'warning'}});
      } else if (stats.max != null) { // It is numeric summary
        return this.handleNumericSummary(stats);
      } else if (results[0].item != null) { // It is a histogram
        return this.handleSummary(results, stats.uniqueValues);
      }
    }); }

    // Need to do this when the query changes.
    clearCachedData() {
      delete this.__suggestions;
      return this.model.unset('error');
    }

    getSuggestions() { return this.__suggestions != null ? this.__suggestions : (this.__suggestions = (() => {
      if (!this.model.get('path')) { return Promise.reject(new Error('no path')); }
      const clone = this.query.clone();
      const value = this.model.get('value');
      const pstr = String(this.model.get('path'));
      const maxSuggestions = Options.get('MaxSuggestions');
      clone.constraints = ((() => {
        const result = [];
        for (let c of Array.from(clone.constraints)) {           if (!((c.path === pstr) && (c.value === value))) {
            result.push(c);
          }
        }
        return result;
      })());

      return clone.summarise(pstr, maxSuggestions);
    })()); }

    replaceInputWithSelect(items) {
      let value;
      if (this.model.has('value')) {
        value = this.model.get('value');
        if ((value != null) && !(_.any(items, ({item}) => item === value))) {
          items.push({item: value});
        }
      } else {
        this.model.set({value: items[0].item});
      }

      return this.$el.html(selectTemplate({Messages, items, value}));
    }

    // Here we supply the suggestions using typeahead.js
    // see: https://github.com/twitter/typeahead.js/blob/master/doc/jquery_typeahead.md
    handleSummary(items, total) {
      let needle;
      if ((needle = this.model.get('op'), ['=', '!='].includes(needle)) && (items.length < Options.get('DropdownMax'))) {
        return this.replaceInputWithSelect(items);
      }

      const input = this.$('.im-con-value-attr');
      const source = new SuggestionSource(items, total);

      const opts = {
        minLength: 0,
        highlight: true
      };
      const dataset = {
        name: 'summary_suggestions',
        source: source.suggest,
        displayKey: 'item',
        templates: {
          footer: source.tooMany
        }
      };

      this.removeTypeAheads();
      const handleSuggestion = (evt, suggestion) => {
        return this.model.set({value: suggestion.item});
      };
      return this.activateTypeahead(input, opts, dataset, items[0].item, handleSuggestion, () => {
        return this.setAttributeValue();
      });
    }
  
    getMarkers(min, max, isInt) {
      const span = max - min;
      const getValue = function(frac) {
        const val = (frac * span) + min;
        if (isInt) { return Math.round(val); } else { return val; }
      };
      const getPercent = frac => Math.round(100 * frac);

      return ([0, 0.5, 1].map((f) => ({percent: getPercent(f), value: numToString(getValue(f))})));
    }

    handleNumericSummary({min, max, average}) {
      let needle;
      const path = this.model.get('path');
      const isInt = (needle = path.getType(), Array.from(INTEGRAL_TYPES).includes(needle));
      const step = isInt ? 1 : (max - (min / 100));
      const caster = isInt ? (x => parseInt(x, 10)) : parseFloat;
      const container = this.$el;
      const input = this.$('input');
      container.append(this.clearer);
      const markers = this.getMarkers(min, max, isInt);
      this.removeSliders();
      input.off('change.slider');
      const $slider = $(this.makeSlider(markers));
      $slider.appendTo(container).slider({
        min,
        max,
        value: (this.model.has('value') ? this.model.get('value') : caster(average)),
        step,
        slide(e, ui) { return input.val(ui.value).change(); }
      });
      input.attr({placeholder: caster(average)});
      container.append(this.clearer);
      input.on('change.slider', e => $slider.slider('value', caster(input.val())));
      return this.sliders.push($slider);
    }

    remove() {
      super.remove(...arguments);
      return this.removeTypeAheads();
    }
  };
  AttributeValueControls.initClass();
  return AttributeValueControls;
})());
