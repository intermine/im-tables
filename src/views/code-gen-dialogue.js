let CodeGenDialogue;
const _ = require('underscore');
const {Promise} = require('es6-promise');

// Base class
const Modal = require('./modal');

// Text strings
const Messages = require('../messages');
// Configuration
const Options = require('../options');
// Templating
const Templates = require('../templates');
// The model for this class.
const CodeGenModel = require('../models/code-gen');
// The checkbox sub-component.
const Checkbox = require('../core/checkbox');
// This class uses the code-gen message bundle.
require('../messages/code-gen');
// We use this xml indenter
const indentXml = require('../utils/indent-xml');
// We use this string compacter.
const stripExtraneousWhiteSpace = require('../utils/strip-extra-whitespace');
// We need access to a cdn resource - google's prettify
const withResource = require('../utils/with-cdn-resource');

// Comment finding regexen
const OCTOTHORPE_COMMENTS = /\s*#.*$/gm;
const C_STYLE_COMMENTS = /\/\*(\*(?!\/)|[^*])*\*\//gm; // just strip blocks.
const XML_MIMETYPE = 'application/xml;charset=utf8';
const JS_MIMETYPE = 'text/javascript;charset=utf8';
const HTML_MIMETYPE = 'text/html;charset=utf8';
const CANNOT_SAVE = {level: 'Info', key: 'codegen.CannotExportXML'};
const MIMETYPES = {
  js: JS_MIMETYPE,
  xml: XML_MIMETYPE,
  html: HTML_MIMETYPE
};

const withPrettyPrintOne = _.partial(withResource, 'prettify', 'prettyPrintOne');

const withFileSaver = _.partial(withResource, 'filesaver', 'saveAs');

const alreadyRejected = Promise.reject('Requirements not met');

const stripEmptyValues = q =>
  _.object((() => {
    const result = [];
     for (let k in q) {
      const v = q[k];
      if (v && (v.length !== 0)) {
        result.push([k, v]);
      }
    } 
    return result;
  })())
;

const canSaveFromMemory = function() {
  if (Array.from(global).includes(!'Blob')) {
    return alreadyRejected;
  } else {
    return withFileSaver(_.identity);
  }
};

module.exports = (CodeGenDialogue = (function() {
  CodeGenDialogue = class CodeGenDialogue extends Modal {
    static initClass() {
  
      // Connect this view with its model.
      this.prototype.Model = CodeGenModel;
  
      this.prototype.parameters = ['query'];
  
      this.prototype.optionalParameters = ['page'];
  
      this.prototype.page = {
        start: 0,
        size: (Options.get('DefaultPageSize'))
      };
  
      this.prototype.body = Templates.template('code_gen_body');
    }

    // We need a query, and we need to start generating our code.
    initialize() {
      super.initialize(...arguments);
      this.generateCode();
      return this.setExportLink();
    }

    // The static descriptive stuff.

    modalSize() { return 'lg'; }

    title() { return Messages.getText('codegen.DialogueTitle', {query: this.query, lang: this.model.get('lang')}); }

    primaryIcon() { return 'Download'; }

    primaryAction() { return Messages.getText('codegen.PrimaryAction'); }

    // Conditions which must be true on instantiation

    invariants() {
      return {hasQuery: "No query"};
    }

    hasQuery() { return (this.query != null); }

    // Recalulate the code if the lang changes, otherwise just re-present it.
    modelEvents() {
      return {
        'change': this.onChangeLang,
        'change:showBoilerPlate': this.reRenderBody,
        'change:highlightSyntax': this.reRenderBody
      };
    }

    // Show the code if it changes.
    stateEvents() { return {'change:generatedCode': this.reRenderBody}; }

    // The DOM events - setting the attributes of the model.
    events() { return _.extend(super.events(...arguments),
      {'click .dropdown-menu.im-code-gen-langs li': 'chooseLang'}); }

    // Get a regular expression that will strip comments.
    getBoilerPlateRegex() {
      if (this.model.get('showBoilerPlate')) { return; }
      switch (this.model.get('lang')) {
        case 'pl': case 'py': case 'rb': return OCTOTHORPE_COMMENTS;
        case 'java': case 'js': return C_STYLE_COMMENTS;
        default: return null;
      }
    }

    act() { // only called for XML data, and only in supported browsers.
      let lang = this.model.get('lang');
      if ((lang === 'js') && this.model.get('extrajs')) { lang = 'html'; }
      const blob = new Blob([this.state.get('generatedCode')], {type: MIMETYPES[lang]});
      const filename = `${ this.query.name != null ? this.query.name : 'name' }.${ lang }`;
      return withFileSaver(saveAs => saveAs(blob, filename));
    }

    onChangeLang() {
      const lang = this.model.get('lang');
      this.$('.im-current-lang').text(Messages.getText('codegen.Lang', {lang}));
      this.$('.modal-title').text(this.title());
      if (['js', 'xml'].includes(lang)) {
        canSaveFromMemory().then(() => this.state.unset('error'))
                           .then(null, () => this.state.set({error: CANNOT_SAVE}));
      } else {
        this.state.unset('error');
      }
      this.generateCode();
      return this.setExportLink();
    }

    generateCode() {
      const lang = this.model.get('lang');
      switch (lang) {
        case 'xml': return this.state.set({generatedCode: this.generateXML()});
        case 'js':  return this.state.set({generatedCode: this.generateJS()});
        default:
          // TODO
          // Safari 8 is caching imjs.fetchCode() even when options
          // change. So, for example, prior results fetchCode('py') are
          // smothering results for fetchCode('java'). Use our own cache for now.
          return this.getCodeFromCache(lang);
      }
    }

    getCodeFromCache(lang) {
      if ((this.cache == null)) { this.cache = {}; }
      if ((this.cache != null ? this.cache[lang] : undefined) != null) {
        return this.state.set({generatedCode: this.cache[lang]});
      } else {
        const opts = {
          query: this.query.toXML(),
          lang,
          date: Date.now()
        };
        // Bust the cache
        return this.query.service.post(`query/code?cachebuster=${Date.now()}`, opts).then(res => {
          this.cache[lang] = res.code;
          return this.state.set({generatedCode: res.code});
        });
      }
    }

    generateXML() {
      return indentXml(this.query.toXML());
    }

    generateJS() {
      const t = Templates.template('code-gen-js');
      const query = stripEmptyValues(this.query.toJSON());
      const cdnBase = Options.get('CDN.server') + Options.get(['CDN', 'imtables']);
      const data = {
        service: this.query.service,
        query,
        page: this.page,
        asHTML: this.model.get('extrajs'),
        imtablesJS: cdnBase + 'imtables.js',
        imtablesCSS: cdnBase + 'main.sandboxed.css'
      };
      return t(data);
    }

    // If the exportLink is null, then CodeGenDialogue#act will be called.
    setExportLink() {
      const lang = this.model.get('lang');
      switch (lang) {
        case 'xml': case 'js': return this.state.set({exportLink: null});
        default: return this.state.set({exportLink: this.query.getCodeURI(lang)});
      }
    }

    // This could potentially go into Modal, but it would need more stuff
    // to make it generic (dealing with children, etc). Not worth it for
    // such a simple method.
    reRenderBody() { if (this.rendered) {
      // Replace the body with the current state of the body.
      this.$('.modal-body').html(this.body(this.getData()));
      // Trigger any DOM modifications, also re-renders the footer.
      return this.trigger('rendered', this.rendered);
    } }

    postRender() {
      super.postRender(...arguments);
      this.addCheckboxes();
      this.highlightCode();
      return this.setMaxHeight();
    }

    setMaxHeight() {
      const maxHeight = Math.max(250, (this.$el.closest('.modal').height() - 200));
      return this.$('.im-generated-code').css({'max-height': maxHeight});
    }

    addCheckboxes() {
      let opt;
      this.renderChildAt('.im-show-boilerplate', new Checkbox({
        model: this.model,
        attr: 'showBoilerPlate',
        label: 'codegen.ShowBoilerPlate'
      })
      );
      this.renderChildAt('.im-highlight-syntax', new Checkbox({
        model: this.model,
        attr: 'highlightSyntax',
        label: 'codegen.HighlightSyntax'
      })
      );
      if (opt = Options.get(['CodeGen', 'Extra', this.model.get('lang')])) {
        return this.renderChildAt('.im-extra-options', new Checkbox({
          model: this.model,
          attr: (`extra${this.model.get('lang')}`),
          label: opt
        })
        );
      }
    }

    highlightCode() { if (this.model.get('highlightSyntax')) {
      const lang = this.model.get('lang');
      const pre = this.$('.im-generated-code');
      const code = this.getCode();
      if (code == null) { return; }
      return withPrettyPrintOne(prettyPrintOne => pre.html(prettyPrintOne(_.escape(code))));
    } }

    getData() { return _.extend(super.getData(...arguments), {
      options: Options.get('CodeGen'),
      generatedCode: this.getCode()
    }
    ); }

    getCode() {
      const code = this.state.get('generatedCode');
      const regex = this.getBoilerPlateRegex();
      if (!regex) { return code; }
      return stripExtraneousWhiteSpace(code != null ? code.replace(regex, '') : undefined);
    }

    // Information flow from DOM -> Model

    toggleShowBoilerPlate() { return this.model.toggle('showBoilerPlate'); }

    toggleHighlightSyntax() { return this.model.toggle('highlightSyntax'); }

    chooseLang(e) {
      e.stopPropagation();
      const lang = this.$(e.target).closest('li').data('lang');
      return this.model.set({lang});
    }
  };
  CodeGenDialogue.initClass();
  return CodeGenDialogue;
})());
