Contributing to the Development of the Library
===============================================

This library is a set of tools which construct user interface
elements in an HTML 5 capable web browser for interaction with
InterMine data-warehouse systems. It is built on the following
technologies:

 * **CoffeeScript** - The language of the library.
 * **Backbone** - An MVC and eventing abstraction layer
 * **Bootstrap** - User interface patterns (in css and javascript)
 * **d3** - Data visualisation
 * **FontAwesome** - Scalable icon font.
 * **Google-Prettify** - Syntax highlighting.

Utility functions are supplied by **underscore.js**, and most DOM
manipulation is performed with **jQuery**. HTTP communication and API
calls are abstracted through **imjs**, the API transport library for
the InterMine project.

Some of these resources can be bundled into the built version of the
library itself, so that it can be served as a single file. Other parts,
such as the d3 SVG manipulation library, are fetched on demand, with
acceptable fallbacks available for their absence.

Getting Started
------------------

A guide to those thinking of developing the tables application and components.
This includes instructions on setting up a development environment, running the
tests, best practices and release procedure.

### Development Environment

#### prerequisites

im-tables is a node-based application. So the first step is to install node and npm (preferably using
a node environment manager such as [nvm](https://github.com/nvm-sh/nvm)).

We assume you have the following global packages:

- browserify
- bower
- grunt
- coffeescript
- brfs

to install, run:

```sh
npm install -g browserify bower grunt coffeescript brfs
```

#### Build library and install dependencies

Install dependencies (and run an initial build):

```sh
npm install
```

Start a development server, which builds (and rebuilds the test indices) and
serves them to the world (and runs the tests):

```sh
npm start
```

To use the test indices you will need a data server running the intermine-demo
application at port 8080 on your machine - you can get this by running the
`testmodel/setup.sh` script in the `intermine/intermine` repo.

### Coding Style

Code contributed to this library is expected to be coffee-script files, following
the standard style conventions of the coffee-script community (two-space indentation,
one-line functions where possible, minimisation of brackets and line noise). See
the coffeelint file for a specification of the style conventions that are
enforced.

All new classes are expected to use the `define/using` dependency management
framework (see below), and keep to the following guidelines:

 * No more than one exported object per file. This should usually be a class.
 * File sizes should not exceed 500 lines. File sizes of less than 200 lines should
   be aimed for.
 * Objects should be exported for external access only very rarely.
 * No raw strings should be present in presentational code. All labels, icons
   and text should live in the `intermine.messages` or `intermine.icons`
   namespaces.

### Code Framework

An important requirement of this library is to be embeddable in as many different
contexts as possible, which means working in circumstances where we do not
have full control over the environment in terms of dependencies, available
libraries, or even versions of the libraries we do have. This means that
where dependencies are used, they are bundled where applicable, and in
general, dependencies are minimised where practical. The project is still
reasonably complex, and tools such as Backbone, Bootstrap and jQuery are employed
to deal with this complexity; but inclusion of other dependencies is strongly
discouraged.

One dependency that would be welcome but which is off the table is require.js.
Nonetheless a code dependency management system is employed within the library
with enables writing modular code. This makes use of two functions defined within
this library itself: `define` and `using`. Please see `DEPENDENCY_MANAGEMENT` for
an introduction to this system and how it should be used.

Backbone is used for managing the complexities of state and presentation. New code is
expected to follow standard MVC design principles where an object models the
domain state, and the presentation layer reflects that state in the DOM.

### Best Practices

This library tries to adhere to the following principles:

 * Being aware that it may be a guest on the page, it should respect its host's
   boundaries. This means all efforts should be made to *avoid global references*.
   This means *no global variables*, no attaching things to the `body`, or
   listening to the `document`, and equally it means prefixing *all* css
   classes with `im-`, to avoid clashing with common css class names. It also means
   all css references but be in the form of DOM structure (element names) or
   css classes. No id attributes are allowed.
 * Being aware that multiple instances of this library may be instantiated, all
   efforts should be made to be as *frugal with resources* as possible. This means
   not making pointless requests before they are actually needed, especially
   if there is any chance they will never be needed. This means *caching* results
   of requests that have been made when we can be confident that we can do so.
   This means cleaning up after yourself, in terms of *deallocating resources*, and
   *unbinding event handlers*.
   This also means *releasing access to potentially shared resources* such as queries,
   for example by cloning them so that each widget has its own independent copies.
 * Being aware that this is an open-source library for use by the scientific
   research community, this library should make no efforts to hide information,
   complexity or choice from its users. *If an action is possible, this library
   should expose it to the end user*. It is the responsibility of the library
   designer to manage the complexity to avoid overwhelming users, and judge the
   right amount of information to present at any one time. There are many tools that
   can be used to help with this, and they should be used when they make things
   simpler, never for their own sake.
 * Aware that repetition is a breeding ground for bugs, the library designer
   should strive, all things being equal, to get by with *as little code as possible*.
   No functions should be duplicated, strings should be references from the
   `intermine.messages` object, available tools should be understood and used
   (make sure you are familiar with all of the Backbone API, especially
   events and the Collection methods). Underscore is available as it is a dependency
   for Backbone, so feel free to utilise it to make your code more concise. Any
   duplication should be seen as an opportunity for refactoring. This also means
   getting by with *as few external dependencies as possible*. New dependencies
   should only be considered if they provide features that are compelling, they
   cannot be made optional and lazily loaded, and they deal with a problem
   domain of sufficient complexity that attempting to tackle it would be more
   likely to produce inefficient, bug filled code than a concise elegant solution.

The present author is well aware that he is guilty of gross infractions of all
of these above principles.
