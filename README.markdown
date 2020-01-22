InterMine Results Tables
=========================

A data display library for InterMine web-applications.

This library provides a highly functional data exploration and
download tool suitable for embedding into any website. It requires
an InterMine data-warehouse to communicate with for data, and a
modern web-browser (IE 10+).

This library is free and open source software, licensed under the
LGPL-v3 licence. A copy of this license is distributed with this repository.

Synopsis
-----------------

```js
    var imtables = require('im-tables');

    var element = document.querySelector('#my-id');
    var service = {root: 'http://www.flymine.org/query/service'};
    var query = {
        select: ['*'],
        from: 'Gene',
        where: [['Gene', 'IN', 'MY-LIST']]
    };

    // Configure options here, using nested notation
    imtables.configure({TableCell: {PreviewTrigger: 'click'}});
    // Or using path names:
    imtables.configure('TableResults.CacheFactor', 20);

    // Then load the table (or indeed vice-versa, the table
    // will respond to changes in the options)
    imtables.loadTable(
        element, // Could also be a string or a jquery object
        {start: 0, size: 25}, // Can be null - all properties are optional.
        {service: service, query: query} // Can also be an imjs.Query object
    ).then(
        function handleTable (table) { /* ... Do something with the table. */ },
        function reportError (error) { console.error('Could not load table', error); }
    );
```

Installation and Usage
-----------------------

This library is developed with Browserify and provides a UMD (Universal
Module Definition) interface to its main entry point. It can thus be loaded
as a commonjs module, from an AMD loader or as a window global. We recommend
using npm and browserify:

```
  npm install --save im-tables
```

Then in your code:

```
  var imtables = require('im-tables');
```

Issues & Support
-----------------

For help and support, the developers may be contacted at:

  http://intermine.org/contact/

For a public bug tracker, please visit the github issues tracker:

  https://github.com/intermine/im-tables/issues

Customisation
--------------

This library is designed to be customised by end users, in every aspect
from its stylesheets and text strings, to the code that defines the 
behaviour of individual components. Please see the file `CUSTOMISING` for
details on how to get started.

Development
-------------

Please see the `CONTRIBUTING` file included in this distribution
for details of how to start developing this library.

Acknowledgements
-----------------

The development work for this library was funded by the NIH and the 
Wellcome Trust as part of the InterMOD model organism datamine project.
It is one of the constituent components of the InterMine data-warehouse
system.

This set of user interface tools would not be possible without the
fantastic set of open source web development tools available today.
We are extremely grateful to benefit from the hard work put into the
development of:

 * Backbone
 * Bootstrap
 * Browserify
 * CoffeeScript
 * d3
 * FontAwesome
 * jQuery & jQuery.UI
 * underscore

Copyright
----------

The copyright on this work is held by Alex Kalderimis, InterMine, and all other authors who have contributed to this repository.
