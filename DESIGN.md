# Design and Architecture

This library is relatively large and complex client side application, and is
only made possible to develop and maintain by adhering to certain design
principles and architectural guidelines. This document discusses the design of
the tables and why these principles were chosen.

## Overview

The application is composed of a number of interacting sub-units with their own
local state and interfaces (eg. cells, headers, buttons, dialogues, etc). These
are developed as separate units of code in commonjs modules and composed into a
single application using Browserify. Browserify was chosen as it is an excellent
choice for breaking down a large application into small, digestible chunks, and
it is superior to Require.js (its only real competitor) in allowing the code to
be further consumed by other parties. It was an important design consideration
that the various sub-units of this application could be re-used separately in
other contexts (eg. the item previews, or the export dialogue). Browserify makes
this easy. The application structure is heavily influenced by Backbone, upon
which it is built.

The code is organised into the following logical divisions:
  * Models: Abstractions defining the state of components. These live in `src/models`
  * Views: Controllers binding UI actions to model behaviour. These live in
    `src/views`. These components also explicitly define the sub-component
    structure of the application, forming a tree of components.
  * Templates: Functions producing HTML markup from data. These live in
    `templates`. Views are responsible for extracting data from models and
    passing it to templates to generate HTML.
  * Utilities: General logic that may be used in multiple places. These live in
    `src/utils`.
  * Messages: Text strings. Separate from templates (which describe DOM
    structure), messages are a mechanism for getting human readable text
    strings. These are designed to be configurable with customisation and
    internationalisation in mind. These are located in `src/messages` and can be
    set at run-time after the application is loaded.
  * Options: A central configuration store, accessible to all components and
    available at run-time to the outside world. Located at `src/options`.

Where possible the code is meant to be as declarative as possible. This means
that readers of the code should be able to see what the code means just from
looking at the code, rather than holding the whole system in their heads - ie.
we are writing for humans and our own sanity and not just for the browser. Some
decisions that flow from this include:
  * The views are the canonical place to look to see how things fit together -
    their job is to bind state to appearance and actions to behaviour so they
    are where these connections are defined. As such the views should name the
    models they expect (in the `::Model` property of the class), the template
    that renders that model (in the `::template` property) and cleanly show what
    transformations are performed (in the `::getData` method).
  * DOM events should never cause a component to manipulate the DOM directly in
    the event handler. DOM events should affect model state, which can, in
    separate handlers, cause DOM manipulation if so required. The flow should be
    `DOM Event` -> `State` -> `State Event` -> `DOM manipulation`. This
    indirection has several benefits: it makes it easier to see what is going on
    (each direction of the binding from DOM <-> State has its own handler), and
    it means that some DOM manipulation can be avoided (if it does not change
    the state).
  * Localising as much of the DOM manipulation in the template is to be
    preferred, ie. prefer to re-render on any state changes rather than
    twiddling the DOM. Rendering even a moderately sized template is fast, and the best
    code structure is to do all State -> DOM binding in the template and fully
    re-render when anything relevant changes. This produces minimal classes
    (with just model, template, getData projection and event binding
    definitions) that are very comprehensible and means things can never get out
    of synch (if you have DOM twiddling you have to be sure to call that
    twiddler on every initial render and re-render and make sure it is
    consistent with the template state). Reasons to do twiddling include if it
    would overwrite a form input (which can be annoying and frustrate the user)
    or in tight loops (eg. the cells do twiddling to avoid re-rendering > 100
    cells on every small change).
  * The flow of concerns means that templates should only deal with presentation
    (never state) and models should only deal with state (never presentation) -
    ie. strong separation of concerns. The views are the place where these two
    things are composed. Hence it follows that models can never refer to views
    and are pure data-structures that never need access to a DOM to run. Models
    should be fully testable in node. Templates should be pure projections of
    data and never encode layers of data for reading out of the DOM (eg. setting
    data attributes so that handlers can access them). Data attributes are a
    major code smell and indicate that another child-component level is needed
    to bind that linkage of state and behaviour.

To make this easier some structure is provided to make life easier:

## Core-View

All views in the application extend `Backbone.View` through a subclass called
`CoreView` (located at `src/core-view`). This provides several important helpers
and lays out a component life-cycle (in this sense it is not dissimilar from
Marionette, but more specilised for this use case).

### Public API

The API for consuming a view is the standard Backbone one - all views are
instantiated with `new` and an options object (ie. all view constructors take a
single argument). Once constructed the method `render` must be called and the
component must be inserted into the DOM. eg:

```js
var view = new Component(opts);
document.querySelector(x).appendChild(view.render().el);
```

`CoreView::render` always returns `this` and never throws.

### Parameters and initialization

Views may (and *should*) specify their parameters through with the `parameters`
property. This means that those reading your class can immediately and
consistenly see how to instantiate the component. Parameters listed in this way
are required, and failing to provide them, or passing a `null` value will cause
an error to be thrown on initialisation. Optional parameters can be listed in
`::optionalParameters`, which may be omitted or set to `null` - which will be
ignored.

Views can (and *should*) define assertions that check that their parameters meet
their expectations as soon as possible. These are termed invariants and there
are two ways of defining them. One is to associate each parameter with an
assertion about its type (see `core/type-assertions`) which is an excellent way
to document your assumptions about your code. More complex assertions may be
provided using the invariants system, eg:

```js
  // We must be provided with a model and a foo.
  parameters: ['model', 'foo'],

  // We require that foo is a Foo, and the model is a model
  parameterTypes: {
    model: types.Model,
    foo: types.InstanceOf(Foo, 'Foo')
  },

  // ... some class

  // mapping from tests to failure messages
  invariants: function () {
    isAdult: "User is not old enough, is only " + this.model.get('age')
  },

  // Each test is a method that returns true if acceptable.
  isAdult: function () {
    return this.model.get('age') >= 18;
  }
```

If no further initialization is required beyond capturing the parameters then
there is no need to override `initialize`. Authors should seek to avoid
overriding `::initialize` where possible, and where they must, then *always*
call super - if `super` is not called then things like parameter setting, model
construction and invariant checking will not be done and things *will* break.
You have been warned.
 
### Model vs. State

Components can have multiple models/collections. An example of this is all
components that receive an `imjs.Query` object as a parameter, which can
function as a model. In addition to whatever they are provided with, all views
are guaranteed to have a `::model` and a `::state` property. These are both
`Backbone.Model` instances, but they are intended to differ in the following ways:

* `model` can be passed as a parameter, whereas each component receives a
  state automatically.
* The `model` is meant to be the canonical representation of the data, whereas
  the state is meant to be the transient and derivative projection of that
  data.
* Models are expected to be shared and passed around, state is meant to be
  private. If state is passed to sub-components it should be the model of the
  sub-component.
* Models are meant to have a defined shape (each view should have an
  appropriate Model class) with specific properties that are
  always present. State is more free-form and can have any properties required.
* In the template the model is exploded (eg. `model.foo` is accessed as `foo`)
  and the state is accessed via `state` (eg. `state.foo` is accessed as
  `state.foo`).

For example, some components receive a model identifying them, and a collection
identifying a set of active components. The logic for these components is:

1. On initialisation the component checks if its model is in the active set,
   and if so sets its `state.active` to `true`.
2. When rendering, the template reads from `state.active`.
3. When the user activates the component the component adds the model to the
   active set.
4. When the user deactivates the component the component removes the model
   from the active set.
5. When the active set changes the component checks if the model is in the
   active set and sets the `state.active` property accordingly.
6. When the `state.active` property changes, the component re-renders (go to
   2.)

This system provides a way for keeping states in synch while maintaining simple
projections from DOM to state and back. It also minimises re-renderings, since
we don't have to re-render all components that share the same active set, just
the ones whose membership changes.

### Event Sets

To keep everything nice and declarative components can define event sets (like
the main `events` property of a basic `Backbone.View`, which handles DOM
events) for other targets, the default ones being `modelEvents`, `stateEvents`
and `collectionEvents`, which listen to events on `::model`, `::state` and
`::collection` respectively. Not every view will have a collection, but if
`collectionEvents` is defined, then it will be checked to exist. These can be
thought of as the other direction of binding: `events` binds from DOM -> Model,
and the other events bind from state -> DOM. The most important action is
`CoreView::reRender`, which calls `render` only if `render` has already been
called. It is thus safe to initialise the state to values we are listening to
since no render will be triggered until the component is mounted.

### The Minimal CoreView

A nice clean component is easy to tell at a glance - it should be short, with
obvious methods and declarative bindings and no calls to super. A simple view
could look something like this:

```js
var SimpleView = CoreView.extend({

    // a model that has .favourite :: bool and .likes :: int attributes
    Model: SimpleViewModel, // see CoreModel below info on swap and toggle

    template: Templates.template('simple-view'),

    // DOM -> State bindings
    events: function () {
        'change .favourite': function (e) { this.model.toggle('favourite'); },
        'click .like': function (e) { this.model.swap('likes', increment); }
    },

    // State -> DOM bindings
    modelEvents: function () {
        'change:favourite change:likes': this.reRender
    }
});

// Helper that increments a value.
function increment (n) { return n + 1; }
```

### Child Management

An important part of components is child management. This is handled by the
following methods:

1.  `CoreView::renderChild(id, child, container = this.el)`:

    Renders a child component, appending it to the container (or `this.el` if
    not provided) and storing a reference to it against the id. `child` should
    be an instance of a `CoreView`.

2.  `CoreView::removeChild(id)`:

    Removes the child by the given id (if it exists). Does nothing if the child
    doesn't exist. This is always called by `renderChild`, and it is called for
    every existing child during `remove`, thus removing all trees of
    sub-children.

3. `CoreView::renderChildAt(selector, child)`:

   Specialisation of `renderChild` - renders a child and sets its element to
   that of the value of `this.$(selector)`.

These methods should be called in `renderChildren` or `postRender` which are the
parts of the life-cycle when the template has rendered the DOM of the current
component. The child can then be accessed at `::children[id]`, although that
should seldom be necessary. An important implication of this is that
child-components should be prepared to be torn-down and rebuilt as frequently as
their parents are re-rendered, and that the higher up the tree one is, the more
stable one will be. Or conversely, re-rendering a component with lots of
sub-components can get expensive.

Best practices are to isolate re-rendering. If a change in state affects that
heading in a component, but not the body, then the header and body should be
separate child components that have separate rendering cycles, even if they
share the same model.

## CoreModel

TODO

## Questions

### Why not just use DataTables

I tried. Hard. The first version of this code was built on DataTables, but I had
to tear it down and start again. DataTables has a number of limitations
including:
  * You can't render complex cells easily, and we needed things like subtables,
    and cells with their own state, and formatting logic and cells that replace
    other cells, etc.
  * Same goes for headers - and this is very tricky as we needed to dynamically
    change the header definition depending on the formatters loaded and the
    outer-join status. Also headers have lots of sub-components such as the
    column summaries.
  * The event system is very limited, and we needed fine grained access to
    things like cell selection.
  * While it has improved massively, styling DataTables used to be very
    challenging.
  * It is fundamentally tied in to a global jQuery which makes it a rather poor
    candidate for embedding on other pages, which was a primary design goal.

Do keep re-investigating this regularly. The best code is the code we don't have
to write or maintain, so if we can delete half this repo that would be great.
