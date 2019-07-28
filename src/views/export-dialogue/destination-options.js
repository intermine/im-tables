// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let DestinationOptions;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Templates = require('../../templates');
const Options = require('../../options');
const Formats = require('../../models/export-formats');

// TODO: allow other destinations to register their options.
class DestinationSubOptions extends CoreView {
  static initClass() {
  
    this.prototype.RERENDER_EVENT = 'change:dest';
  
    // These are stored at class definition time to avoid reparsing the templates.
    this.prototype.galaxyTemplate = Templates.template('export_destination_galaxy_options');
  }

  initialize() {
    super.initialize(...arguments);
    return this.listenTo(Options, 'change:Destination.Galaxy.*', this.reRender);
  }

  getData() { return _.extend(super.getData(...arguments), {Galaxy: Options.get('Destination.Galaxy')}); }

  // Dispatches to the template to use.
  getTemplate() { switch (this.model.get('dest')) {
    case 'Galaxy': return this.galaxyTemplate;
    default: return (() => '');
  } }

  template(data) { return this.getTemplate()(data); }

  events() {
    return {
      'change .im-galaxy-uri-param': 'setGalaxyUri',
      'change .im-save-galaxy input': 'toggleSaveGalaxy'
    };
  }

  setGalaxyUri({target}) { return Options.set('Destination.Galaxy.Current', target.value); }

  toggleSaveGalaxy() {
    const key = 'Destination.Galaxy.Save';
    const current = Options.get(key);
    return Options.set(key, (!current));
  }
}
DestinationSubOptions.initClass();

class RadioButtons extends CoreView {
  static initClass() {
  
    this.prototype.RERENDER_EVENT = 'change:dest';
  
    this.prototype.template = Templates.template('export_destination_radios');
  }

  destinations() { return ((() => {
    const result = [];
    for (let d of Array.from(Options.get('Destinations'))) {       if (Options.get(['Destination', d, 'Enabled'])) {
        result.push(d);
      }
    }
    return result;
  })()); }

  getData() { return _.extend({destinations: this.destinations()}, super.getData(...arguments)); }

  setDest(d) { return () => this.model.set({dest: d}); }

  events() { return _.object( Array.from(this.destinations()).map((d) => [`click .im-dest-${ d }`, this.setDest(d)])); }
}
RadioButtons.initClass();

module.exports = (DestinationOptions = (function() {
  DestinationOptions = class DestinationOptions extends CoreView {
    static initClass() {
  
      this.prototype.RERENDER_EVENT = 'change:format';
  
      this.prototype.template = Templates.template('export_destination_options');
    }

    getData() {
      const types = this.model.get('has');
      const formats = Formats.getFormats(types);
      return _.extend({formats}, super.getData(...arguments));
    }

    postRender() {
      this.renderChildAt('.im-param-dest', (new RadioButtons({model: this.state})));
      return this.renderChildAt('.im-dest-opts', (new DestinationSubOptions({model: this.state})));
    }

    events() {
      const evts =
        {'.change .im-param-name input': 'setName'};

      const types = this.model.get('has');
      for (let fmt of Array.from(Formats.getFormats(types))) {
        evts[`click .im-fmt-${ fmt.id }`] = this.setFormat.bind(this, fmt);
      }
      return evts;
    }

    setName(e) { return this.model.set({filename: e.target.value}); }

    setFormat(format) { return this.model.set({format}); }
  };
  DestinationOptions.initClass();
  return DestinationOptions;
})());

