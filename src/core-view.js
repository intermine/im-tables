let CoreView;
require('./shim'); // This loads jquery plugins and sets up Backbone
const Backbone = require('backbone');
const _ = require('underscore');
const $ = require('jquery');

const CoreModel = require('./core-model');
const Messages = require('./messages');
const Templates = require('./templates');
const Icons = require('./icons');
const Event = require('./event');

let helpers = require('./templates/helpers');
const onChange = require('./utils/on-change');

// We only need one copy of this - it is a very generic throbber.
const IndeterminateProgressBar = (Templates.template('progress-bar'))({doneness: 1});

// private incrementing id counter for children
let kid = 0;

const getKid = () => kid++;

// Private methods.
const listenToModel = function() { return listenToThing.call(this, 'model'); };
const listenToState = function() { return listenToThing.call(this, 'state'); };
const listenToCollection = function() { return listenToThing.call(this, 'collection'); };
var listenToThing = function(thing) {
  const definitions = _.result(this, `${ thing }Events`);
  if (!_.size(definitions)) { return; }
  if (this[thing] == null) { throw new Error(`Cannot listen to ${ thing } - it is null.`); }
  return (() => {
    const result = [];
    for (let event in definitions) {
      let handler = definitions[event];
      handler = _.isFunction(handler) ? handler : this[handler];
      if (handler == null) { throw new Error(`No handler for ${thing}:${event}`); }
      result.push(this.listenTo(this[thing], event, handler));
    }
    return result;
  })();
};

// Class defining the core conventions of views in the application
//  - adds a data -> template -> render flow
//  - adds @make helper
//  - ensures @children, and their clean up (requires super call in initialize) 
//  - ensures @model :: CoreModel (requires super call in initialize)
//  - ensures @state :: CoreModel (requires super call).
//  - ensures the render cycle is established (preRender, postRender)
//  - starts listening to the RERENDER_EVENT if defined.
module.exports = (CoreView = (function() {
  let hasAll = undefined;
  CoreView = class CoreView extends Backbone.View {
    static initClass() {
  
      this.prototype.hasOwnModel = true; // True if the model does not belong to anyone else
  
      // Properties of the options object which will be made available on the
      // view at @[prop]. Additionally, their presence (via non-null check)
      // will be asserted as an invariant.
      this.prototype.parameters = [];
  
      // Properties of the options object which will be made available on the
      // view at @[prop]. Default values should be provided on the prototype,
      // which will then be overriden but available to other instances.
      this.prototype.optionalParameters = [];
  
      // Type assertions, one for each parameter, keyed by parameter name.
      //
      // An assertion is an object with the following structure:
      //   test :: (value :: Any) -> bool
      //   message :: (name :: String) -> String
      // 
      // Types do not need to be defined for all parameters, but they will be asserted if they are.
      this.prototype.parameterTypes = {};
  
      this.prototype.ICONS = 'change';
  
      // Declarative model event binding. Use these hooks rather than
      // binding in initialize.
  
      // The list of model attributes that must be present to render.
      // If not available yet,
      // the view will listen until they are.
      this.prototype.renderRequires = [];
  
      // The model events that we should listen to, eg: {'change:foo': 'reRender'}
      this.prototype.modelEvents = {};
  
      // The state events that we should listen to, eg: {'change:foo': 'reRender'}
      this.prototype.stateEvents = {};
  
      // The collection events that we should listen to, eg: {'change:foo': 'reRender'}
      this.prototype.collectionEvents = {};
  
      hasAll = (model, props) => _.all(props, p => model.has(p));
  
      this.prototype.removed = false;
    }

    static include(mixin) { return _.extend(this.prototype, mixin); }

    // Implement this method to set values on the state object. Well, that is
    // the purpose at least. Called after variants have been asserted.
    initState() {}

    initialize(opts) {
      let left, left1;
      if (opts == null) { opts = {}; }
      this.state = opts.state; // separate to avoid override issues in parameters
      const params = ((left = _.result(this, 'parameters'))) != null ? left : [];
      const optParams = ((left1 = _.result(this, 'optionalParameters'))) != null ? left1 : [];
      // Set all required parameters.
      _.extend(this, _.pick(opts, params));
      // Set optional parameters if provided.
      for (let p of params) { // Ignore if null.
        if (opts[p] != null) {
          this[p] = opts[p];
        }
      }
      this.children = {};
      const Model = (this.Model || CoreModel);
      if ((this.model != null ? this.model.toJSON : undefined) != null) { this.hasOwnModel = false; } // We did not create this model
      if (this.model == null) { this.model = new Model; } // Make sure we have one
      if (this.model.toJSON == null) { this.model = new Model(this.model); } // Lift to Model

      if (this.state == null) { this.state = new CoreModel; } // State holds transient and computed data.
      if (this.state.toJSON == null) {
        this.state = new CoreModel(this.state);
      }
      if (this.RERENDER_EVENT != null) {
        this.listenTo(this.model, this.RERENDER_EVENT, this.reRender);
      }

      this.on('rendering', this.preRender);
      this.on('rendered', this.postRender);
      this.assertInvariants();
      this.initState();
      listenToModel.call(this);
      listenToState.call(this);
      listenToCollection.call(this);
      this.listenTo(Icons, this.ICONS, function() { if (this.template) { return this.reRender(); } });
      return this.listenTo(this.model, 'destroy', function() { return this.remove(); }); // Specialise what icons to listen to here.
    }

    // Restricted arity version of @stopListening - just takes an object,
    // no event names or whatnot. The purpose of this is to be used in event
    // listeners listening for removal events, eg:
    //
    //   destroy: @stopListeningTo
    //
    // rather than:
    //
    //   destroy: (m) -> @stopListening m
    stopListeningTo(obj) { return this.stopListening(obj); }

    // Sorthand for listening for one or more change events on an emitter.
    listenForChange(emitter, handler, ...props) {
      if (!(props != null ? props.length : undefined)) { throw new Error('No properties listed'); } // Nothing to listen for.
      return this.listenTo(emitter, (onChange(props)), handler);
    }

    renderError(resp) { return renderError(this.el)(resp); }

    // the helpers, cloned to avoid mutation by subclasses.
    helpers() { return _.extend({IndeterminateProgressBar}, helpers); }

    getBaseData() {
      helpers = _.result(this, 'helpers');
      const labels = _.result(this, 'labels');
      return _.extend({state: this.state.toJSON(), Messages, Icons, labels}, helpers);
    }

    // By default, the model and collection, extending state, helpers, labels, Messages and Icons
    getData() { let left;
    return _.extend(this.getBaseData(), this.model.toJSON(), {collection: ((left = (this.collection != null ? this.collection.toJSON() : undefined)) != null ? left : [])}); }

    // Like render, but only happens if already rendered at least once.
    reRender() {
      if (this.rendered && !this.removed) { this.render(); }
      return this;
    }

    // Default post-render hook. Override to hook into render-cycle
    postRender() {}

    // Default pre-render hook. Override to hook into render-cycle
    preRender() {}

    onRenderError(e) {
      console.error('RENDER FAILED', this, e);
      return this.state.set({error: e});
    }

    // Safely remove all existing children, apply template if
    // available, and mark as rendered. Most Views will not need
    // to override this method - instead customise getData, template
    // and/or renderChildren, preRender and postRender
    render() {
      if (this.removed) { return; }
      const requiredProps = _.result(this, 'renderRequires');
      if ((requiredProps != null ? requiredProps.length : undefined) && (!hasAll(this.model, requiredProps))) {
        const evt = onChange(requiredProps);
        this.listenToOnce(this.model, evt, this.render);
        return this;
      }

      const prerenderEvent = new Event(this.rendered);
      this.trigger('rendering', prerenderEvent);
      if (prerenderEvent.cancelled) { return this; }

      this.removeAllChildren();

      if (this.template != null) {
        try {
          this.$el.html(this.template(this.getData()));
        } catch (e) {
          this.onRenderError(e);
        }
      }

      this.renderChildren();

      this.trigger('rendered', (this.rendered = true));

      return this;
    }

    renderChildren() {} // Implement this method to insert children during render.

    // Renders a child, appending it to part of this view.
    // Should happen after the main view is rendered.
    // The child is saved in the @children mapping so it can be disposed of later.
    // the child may be null, in which case it will be ignored.
    // A name really ought to be supplied, but one will be generated if needed.
    // If no container is given, the child is appended to the element of this view.
    renderChild(name, view, container, placement) {
      if (container == null) { container = this.el; }
      if (placement == null) { placement = 'append'; }
      if (name == null) { name = getKid(); }
      this.removeChild(name);
      this.children[name] = view;
      if (view == null) { return this; }
      switch (placement) {
        case 'append': view.$el.appendTo(container); break;
        case 'prepend': view.$el.prependTo(container); break;
        case 'at': view.setElement(container[0] || container); break;
        default: throw new Error(`Unknown position: ${ placement }`);
      }
      view.render();
      return this;
    }

    // Render a child and rather than appending it set the given element
    // as the element of the component.
    //
    // Can be called as:
    //   this.renderChildAt '.modal-body', body
    //
    renderChildAt(name, view, element) {
      if (element == null) { element = this.$(name); }
      return this.renderChild(name, view, element, 'at');
    }

    // Remove a child by name, if it exists.
    removeChild(name) {
      if (this.children[name] != null) {
        this.children[name].remove();
      }
      return delete this.children[name];
    }

    removeAllChildren() {
      if (this.children != null) { // Might have been unset.
        return Array.from(_.keys(this.children)).map((child) =>
          this.removeChild(child));
      }
    }

    remove() { if (!this.removed) { // re-entrant
      this.stopListening();
      this.removed = true;
      this.$el.parent().trigger('childremoved', this); // Tell parents we are leaving.
      this.trigger('remove', this);
      if (this.hasOwnModel) { this.model.destroy(); } // Destroy the model if we created it.
      this.removeAllChildren();
      this.off();
      super.remove(...arguments); // actually remove us from the DOM (see Backbone.View)
      return this;
    } }

    // eg: this.make('span', {className: 'foo'}, 'bar')
    make(elemName, attrs, content) {
      const el = document.createElement(elemName);
      const $el = $(el);
      if (attrs != null) {
        for (let name in attrs) {
          const value = attrs[name];
          if (['class', 'className'].includes(name)) {
            $el.addClass(value);
          } else {
            $el.attr(name, value);
          }
        }
      }
      if (content != null) {
        if (_.isArray(content)) {
          for (let x of Array.from(content)) { $el.append(x); }
        } else {
          $el.append(content);
        }
      }
      return el;
    }

    // Machinery for allowing views to make assertions about their initial state.
    invariants() { return {}; }

    assertInvariant(condition, message) { if (!condition) { throw new Error(message); } }

    assertInvariants() {
      let left, left1, left2, message, p, v;
      const params         = ((left = _.result(this, 'parameters'))) != null ? left : [];
      const optionalParams = ((left1 = _.result(this, 'optionalParameters'))) != null ? left1 : [];
      const paramTypes     = ((left2 = _.result(this, 'parameterTypes'))) != null ? left2 : {};

      // Assert that we have all our required parameters.
      for (p of Array.from(params)) {
        v = this[p];
        this.assertInvariant((v != null), `Missing required option: ${ p }`);
      }

      // Assert that all our parameters (optional and required) meet their
      // expectations.
      for (p of Array.from(params.concat(optionalParams))) {
        const typeAssertion = paramTypes[p];
        if (typeAssertion != null) {
          // The constract of these calls is that they are evaluated in this order, so
          // that ::message() has access to data collected during ::test() (if it wants to do
          // so. DO NOT REORDER.
          v = this[p];
          const assertion = typeAssertion.test(v);
          message = typeAssertion.message(p);
          this.assertInvariant(assertion, message);
        }
      }

      // Assert any other more specific invariants.
      return (() => {
        const result = [];
        const object = this.invariants();
        for (let condition in object) {
          message = object[condition];
          result.push(this.assertInvariant((_.result(this, condition)), message));
        }
        return result;
      })();
    }
  };
  CoreView.initClass();
  return CoreView;
})());
