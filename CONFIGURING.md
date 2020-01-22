# Configuration

The Results Tables are designed to be highly configurable. Four primary aspects
of their appearance and behaviour can be customised:

* Text Strings (Messages)
* Run-Time Options
* Cell Formatters
* Custom Stylesheets

## Text Strings

All the human-readable text strings can be configured, eg:

```js
var imtables = require('im-tables');
imtables.setMessages({
    'columns.DialogueTitle': 'Spalten Bearbeiten',
    'columns.ApplyChanges': 'Änderungen Übernehmen'
});
```

This can be used for internationalisation, or simply for customisation. All
messages are located in `src/messages`, if you would like to see what messages
can be customised.

The value of a message can be a string, in which case it will compiled into an
underscore template, or a function, in which case it will be called with a data
object (possibly empty, never null).

## Run Time Options

Many configuration aspects are read out of a configuration object, which exposes
a configuration API, eg:

```js
var imtables = require('im-tables');
imtables.configure({
    CodeGen: {
        Default: 'rb' // Encourage rubyists
    },
    Tables: {
        CacheFactor: 5 // less caching
    },
    NUM_SEPARATOR: '.' // Euro style thousands.
});
```

Configuration can be done using nested objects, as above, or using dot-separated
paths, as below:

```js
var imtables = require('im-tables');
imtables.configure('CodeGen.Default', 'rb');
imtables.configure('Tables.CacheFactor', 5);
imtables.configure('NUM_SEPARATOR', '.');
```

The full list of options with their default values is listed in the
`src/options.coffee` file. Some of the more important ones are listed below:

Key                            | Default Value  | Usage
-------------------------------|----------------|------------------------------------
INITIAL_SUMMARY_ROWS           | 1000           | The number of rows to fetch in the column summaries.
DefaultPageSize                | 25             | The default number of rows on a page.
TableResults.CacheFactor       | 10             | The number of pages to fetch at a time.
Events.ActivateTab             | 'mouseenter'   | How to activate the download tabs.
TableCell.PreviewTrigger       | 'hover'        | Action that shows an item's summary
TableCell.IndicateOffHostLinks | true           | Show a global icon for off host links
Galaxy.Main                    | "http://main.g2.bx.psu.edu" | Default Galaxy installation.
Galaxy.Current                 | null           | The current Galaxy location (eg. when referred).
icons                          | "fontawesome"  | Which icon set to use.
ShowHistory                    | true           | Show the undo history.
PieColors                      | "category10"   | D3 palette or function for pie chart segment colours.

## Formatters

The way a cell is displayed is configurable through the use of formatters.
These are functions (or rather callable things) that take an item and render it
to HTML. These can render a single cell value or combine multiple cell values
into a single display unit. An example of this is the Chromosome-Location
formatter, which displays location information in familiar strings such as
`2L:123...456`. These are straightforward to implement, using a helper provided
with imtables that will suffice for most cases. The Chromosome-Location
formatter is implemented as follows:

```js
var simpleFormatter = require('im-tables/build/utils/simple-formatter');

module.exports = simpleFormatter(
    'Location', // The type of thing this formatter handles
    ['locatedOn.primaryIdentifier', 'start', 'end'], // The fields it formats
    function (loc) {
        return loc['locatedOn.primaryIdentifier'] + ':' + loc.start + '..' + loc.end;
    }
);
```

The use of simple formatters makes defining formatting functions simple and
declarative. Any fields which are required but not present in the query will be
fetched separately.

To activate a formatter, it needs to be registered against its class:

```js
var imtables = require('im-tables');
imtables.formatting.registerFormatter(
    formatter,
    'genomic',
    'Location',
    ['start', 'end', 'locatedOn.primaryIdentifier']
);
```

## Custom Style-Sheets

The style for imtables is built with less, which makes it easier to produce
themed styles for integrating the tables into other web-page environments. A
tool is provided for this purpose: `create-imtables-style`

To use it, pass the name of your theme additions to it, and it will compile a
new style sheet and print the css to standard-out:

```sh
create-imtables-style /path/to/my/themes.less > mytheme.css
```

One of the great advantages of this approach is that you only need to tweak the
things you want to, and most of those are in the form of variables that can be
redefined. An example of how to use this can be found in
`test/less/custom-overrides.less` where you can see the use of variable
redefinition and new style creation. You can use all of less here, including
relative imports.

A more advanced approach is to include the imtables stylesheet into your own
less stylesheet system (much as imtables includes bootstrap and fontawesome). As
long as you make sure bootstrap and fontawesome are on the include path, this
can be added to your build process.

To get started with customisation, take a look at the variables as defined in
`less/variables.less`.
