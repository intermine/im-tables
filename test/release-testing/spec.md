Release Testing
==================

Before each release, the following specification must be verified
by human testers. Any deviation from this spec is a bug, and should
be reported at [https://github.com/alexkalderimis/im-tables/issues.]()

Table Layout
-------------

A rendered table must have:
* A description stating the total result set size, and the range of the
  currently displayed rows. eg: `Showing 1 to 10 of 500 rows`
* A selector for the number of rows to show. (see [row selector](#row-selector)).
* A set of controls for changing the range of currently displayed rows
  (see [pagination](#pagination)).
* A button that will open a dialogue for managing the selected view columns
  and the table sort order (see [column management](#column-management)).
* A button that will open a dialogue for seeing the currently applied filters
  and adding new filters (see [filter management](#filter-management)).
* A button that provides access to code generation (see
  [code generation](#code-generation)).
* A button that provides access to the results export interface (see
  [export](#export)).
* A table with:
  - An informative column header that matches each column (see [column headers](#column-headers)).
  - Rows of [result cells](#result-cells) that match the number displayed in the table description.

If the current user is authenticated (all users in an intermine web-application
should be authenticated), then there must also be:
* A button that will open a set of interfaces for constructing lists from
  results in the table (see [list management](#list-management)).

If the table has been altered since creation, an interface must be
displayed indicating that the change can be undone. (see [query trail](#query-trail)).

Row Selector
--------------

The row selector must:
* display the current number of rows
* offer a suitable range of row sizes.

At any given time:
* there must not be any more rows in the table than the number of
  rows displayed in the row selector.
* There may be fewer rows in the table, but this in this case:
  The table description must indicate that the current range of rows includes
  the end of the result set.

If a user clicks on one of the options
* the table must change to show more or fewer rows so that the previous
  statements are true.


Pagination
-----------

The pagination controls must:
* Display an option for going to the first page.
* Display an option for going to the last page.
* Display an option for advancing by one page.
* Display an option for going back by one page.
* Display an option for going forward by five pages.
* Display an option for goind backwards by five pages.
* Display a mechanism for going to an artitrary page:
 - for reasonably small result sets, this control should be a dropdown selector.
 - for large result sets this selector should allow for any page number
   to be entered in a text input box. For any number entered in a text box:
   - The number should be accepted by pressig enter or by clicking
     on an explicit acceptance button.
   - The number should not be accepted if it is negative, 0, or outside
     the range of available pages.
   - The number should not be accepted for any entry that is not a valid number.

After paginating:
* No row that was previously displayed should now be displayed.

At any time the buttons that make no sense should be disabled, ie:
* the `go to start` button should not be available if already at
  the start.
* The `go to end` button should not be available if already at
  the end.
* The go forward and backwards buttons should be disabled if there no
  forward and backwards pages to go to (depending on the size of the step).

Column Management
------------------

The column management interface must:
* Indicate the current selected columns.
* Allow users to reorder the currently selected columns
  - Reordering should be supported through drag-and-drop.
  - There should be buttons to promote or demote a column.
  - Columns in an outer-joined group must be moved as a unit
  - Formatted columns must be moved together.
* Allow users to remove columns from the view.
* allow new columns to be added to the selected view.
  - Only attributes may be selected.
  - Currently selected columns must be indicated, and not be selectable.
  - Reverse references should be disabled by default, but should be
    selectable if the user chooses to make them so.
* Indicate the current state of the sort order (which elements are
  in the sort order, and which direction they are sorted in).
* Allow the sort order elements to:
  - be reordered (through dragging, and button clicks).
  - have their directions changed
  - Be removed from the sort order.
* Allow new columns to be added to the sort order.
* Not allow duplicate columns
* If the cancel button is pressed, no queued changes may be applied.
* If the apply changes is pressed, all changes must be applied.

Filter Management
-------------------

The filter management interface must:
* Display all the current filters in a readable manner.
* Offer facilities to edit each filter (see [editing filters](#editing-filters)).
* Allow the user to add a new filer to the query:
  - This should open a new dialogue
  - All constrainable columns should be presented.
  - Users should be able to select attributes and references.
  - Users should be given an opportunity to confirm their selection
  - The new constraint should have appropriate initial values.
  - The new constraint should be edited in the same manner as when
    editing an existing constraint (see [editing filters](#editing-filters)).
  - Adding the `add filter` button should add the new filter.

Editing Filters
----------------

When editing a constraint, a user should have the option to:
* Change the operator
  - This should make it so that appropriate input selectors are displayed for that
    operator.
  - Only allow the operators to be changed to something that makes sense
    - Attribute paths should be able to be constrained with:
      `=`, `!=`, `>`, `<`, `>=`, `<=`, `IS NULL`, `IS NOT NULL`, `ONE OF`, `NONE OF`, `CONTAINS`
    - Boolean paths should be able to be constrained with:
      `=`, `!=`, `IS NULL`, `IS NOT NULL`
    - Reference paths should be able to be constrained with:
      `=`, `!=`, `LOOKUP`, `IN`, `NOT IN`, where `=`, and `!=` refer to loop constraints.
  - In any given state, the input box should give appropriate suggestions.
    - If the constrained path is string-ish, then a dropdown should be presented, with
      autocomplete of available values.
    - If the operator is a list operator, then the input should autocomplete the names
      of suitable available lists.
    - If the constrained path is numeric, and summary information is available, a slider
      should be presented to indicate the available range for this constraint, taking
      into account the other constraints present on the query.
* Change the value
  - By entering a value, or a normal attribute constraint
  - using a slider in the case of numeric paths.
  - By clicking the checkboxes of the selected elements, in the case of multi-value constraints.
* Cancel the editing operation, and return to the current state of the query.
* Apply the changes made to the query

At all times:
* The summary should present the current state of the constraint being edited.

Code Generation
-----------------

The user should be able to see formatted, syntax highlighted code generated for the
current query in any of the supported languages. This should:
* Present the user with a choice of language.
* Set the last used language as the default for future uses of this button.
* Allow the user to download the generated code to their own computer.
* Indicate the correct version of the client library to use [! NOT IMPLEMENTED]
* Remember the user's preferred language [! NOT IMPLEMENTED]

Export
------

The user should be able to get files representing all or part of the result set. So:
* Clicking on the export button should open an interface for configuring export options
* If the user clicks the primary `download` button immediately, without setting any
  options 
  - Something useful should be downloaded
  - The page should not navigate away.

Format options should be available such that:
* If the user selects a different format (`csv`, `xml`, `json`...) and clicks download
  - A file in the corresponding format should be downloaded
* Only those format options that make sense should be displayed. eg; if the query
  is `{select: ['Organism.*']}` then only the basic format options should be displayed,
  whereas if the query is `{select: ['Gene.symbol', 'organism.taxonId']}` then
  the `FASTA`, `GFF3` and `BED` format options should also be displayed.
* The user's preferred format should be remembered across sessions (not implemented, see #37).

Column selection options should be available such that:
* The user is able to reorder the columns freely. No limits should be placed on which
  column can go next to any other column.
* The user is able to mute any columns, meaning they will not be displayed in the exported
  results. A muted column should not alter the results in any way.
* The user is able to add any column to the exported results that will not alter the
  results themselves.
* If the current format is not column orientated, but instead node orientated (such as
  the biological formats), the
  - A mechanism should be presented allowing the user to select only the available nodes.
  - The correct arity of the node should be indicated, and errors should be displayed if
    the user selects an incorrect arity.
  - The user should not be allowed to re-order the expored nodes (which makes no sense anyway).

Row selection options should be available:
* If the current format is row orientated.
* Such options should allow the selection of any slice of the result set. This should allow
  text entry and gestural interaction

Exta output options should be available, such that:
* The compression of the output can be specified.
* Appropriate options are available for each format, including:
  - Spreadsheet formats (tsv, csv):
    - column headers
  - GFF3 and FASTA
    - extra attributes
  - FASTA
    - extension
  - BED
    - whether or not to add the `chr` prefix

Destination options should be configurable so that
* The user can decide whether to download the file directly or export it to a 3rd party.
* When downloading:
  * The user should be able to see the link used to download the data. 
  * The user should be able to see the xml query used to download the data.
* External export options should include:
  - [Galaxy](#galaxy)
  - [Genomespace](#genomespace)

At all times
* The inferface should indicate what format the data would be exported in if the user were
  to click on the primary download button.
* The interface should indicate how many columns/nodes of the query are to be exported
* The interface should give some indication of the resulting download size
* The interface should give some indication of where the data is to be exported to.
* The downloaded data should faithfully reflect the current contents of the table

Export must work with queries that require access to private data (such as a private
user's list). 

Galaxy
-------

* The main public Galaxy instance should be used by default, unless the user has a different
  preferred galaxy.
* The interface should offer to save the galaxy url if the user enters a custom one.
* The galaxy interface should open in a new window
* Clicking on the primary button should initiate the export to galaxy
* The export should succeed, and contain appropriate data.

Genomespace
-------------

* The upload interface should display a Genomespace login form
* When logged in, the user should be prompted to complete the upload.
* The export should succeed.
* When complete, the user should be returned to the export form as it was.

Column Headers
---------------

Each column of the table should have an informative column header. The header should
* Display a relevant name.
  - For top level attributes, this should not include the class name, but that should be
    available as needed (on hover by example).
  - The full path should be available if required (on click for example).
  - If the values of this column are formatted (see [formatters](#formatters)) then the path
    displayed should treat this column as representative of the whole class.
* Offer the facility to resort the table by the values in that column 
  - Clicking on an unsorted column should completely replace the sort order
    - This action should be [undo-able](#query-trail)
  - Clicking on a sorted column should reverse the sort direction.
  - This facility should not be offered on outerjoined columns
  - Sorting a formatted column (see [formatters](#formatters)) should sort by the
    underlying value if it is singular, or by the equivalent composite value in the case
    of composite formatters.
* Allow columns to be removed from the query
  - This action should be [undo-able](#query-trail)
  - This action may change the result set structure.
* Allow columns to be hidden
  - A hidden column takes up less space, its values are not visible, but it is still indicated
  - This action is not [undo-able](#query-trail)
  - This action may not change the result set structure.
* Allow the user view and edit/remove the filters that operate on values in the given column
  - When editing a filter in this interface the user should have all the same options
  affored by any other filter editing interface (see [editing filters](#editing-filters)).
* Indicate if any of the constraints in the query operate on the values in this column.
* Allow the user to view a summary of the data in the column. See [column summaries](#column-summaries).       

Column Summaries
-----------------

A column summary should help the user grasp the overall distribution of data in the given column.

For numeric data:
* A histogram should be displayed (in ie >= 9, and all other browsers), indicating the binning
  of the data over its range. No more than 20 bins should be displayed.
* The summary statistics should be displayed, including
  - minimum value
  - maximum value
  - mean value
  - standard deviation
* An interface should be supplied for limiting this range
  - This should include input boxes for `from` and `to` values.
  - This should include an appropriate gestural interface (such as a slider)
  - This should interact with the histogram if displayed (indicating the selected range, and allowing
  clicks on the histogram itself.
  - Filters should only be added to the query if the range is different from the current one.

For non-numeric data:
* A chart should be displayed indicating how many times each unique value in the column appears. If the
  number of unique values is small and one can map each root row to a single value then this data
  may be displayed proportionally (such as in a pie chart).
  - Hovering on sections of the chart should highlight matching rows in the table (see below).
* The items available should be listed, along with how many times each appears.
  - The user should be able to filter the listing of items to find ones they are interested in.
* If more are available on the server than were fetched, then this should be indicated (typically
  1,000 items are fetched initially).
  - in this case, the rest of the items should be retrievable.
* An interface should be supplied for constructing a filter based on the contents of this summary
  - The user should be able to select items from either the chart or the table
  - The user should be able to invert their selection. If the table was scrolled, then this action
    should not change the scroll position of the list.
  - The user should be able to unselect everything selected.
  - The currently selected items should be indicated in the table and in the chart.
  - The user should be able to filter in (restricting to matches), or out (excluding matches).
  - The table should have applied the most efficient form of this constraint:
    - If there was a single item, then this should be as `=` or `!=`
    - If the user selected more than half the items, and we know what they all are, then the
      constraint should be inverted.
* An interface should be supplied for downloading the data used to construct this column summary.
  - This should offer a range of formats. 
  - The downloaded data should match the data in the column summary.
  - The page should not be redirected.

For columns that represent multiple paths of values in the underlying query (such as composite values
or outerjoined values) then the value to summarise should be selectable.

Result Cells
------------

* Should indicate that one may interact with them (such as through a highlight colour).

* If the cell represents a subtable of outerjoined results, it should be collapsed and
  indicate the number of subrows.
  - The column headers of sub-tables should not contain all the controls of the main table, although they
    should allow the sub-column to be removed.
  - Sub-table may contain their own result cells, and nested sub-tables.

* If the cell represents a single value, then it should
  - display the value for this cell, formatted according to the current configuration 
  (see [formatters](#formatters)).
  - Contain a link to a report page of some kind. If this report page is on a different domain
  to the one serving the tables javascript source, and the option `intermine.options.IndicateOffHostLinks`
  is set to true, then an external link indicator should be visible.
  - On click in the display a relevant summary of the object this is a value of
  (see [object summaries](#object-summaries)).

* If the cell represents a composite value then it should not appear fundamentally different
  from the other cell types.

List Management
----------------

List management should not be available if the user is not authenticated.

Clicking on the list management button should provide two modes:
* Create new list
* Add to existing list

And it should offer several starting points, consisting of one option for
all the objects in each column, and one option to pick and choose.
* Hovering over each option should highlight the cells that each option refers to.

If the user chooses to add all items from a column, then
* the relevant dialogue should open up.
* It should be a modal dialogue, preventing interaction with the table.

If the user chooses to pick and choose from the table, then
* A floating dialogue should appear, with an instructional message.
* The user should be able to move this dialogue around
* The cells of the table should now have checkboxes visible within them.
* Clicking on a cell should no longer open up an object summary, but should add items to the
  list operation.
  - When a table cell is selected, all the cells that represent that same object should be selected
  - When at least one item is selected, only those cells that are type-compatible with the
    currently selected cells should still display their checkboxes.

If the user is creating a new list:
* The form displayed should have entry options for
  - The name, description and tags of the new list
  - The name input should be prepopulated with a sensible and unique name.
  - The tags entry interface should autocomplete with the user's current tags
  - Sensible and useful suggestions for tags should be available.
    - The user should be able to add some, or none, or all of the suggestions and complete the task
      successfully.
    - Once added, a suggestion should be able to be removed. When removed, the tag should appear back
      in the suggestions box.
    - Tags the user has added manually but then removed should be visible in the suggestions box.
* If the user is picking from the table, there should be the ability to minimise the size of the form
  so the user can see as much of the table as possible.

If the user is adding to an existing list, the user should be presented with a selection of compatible
lists that the user could add the items to.
* The number of items to add to the list should be indicated.
* If the user is picking from the table, there should be the ability to minimise the size of the form
  so the user can see as much of the table as possible.

* Clicking on reset should empty the form of entered and default values, but not change the selected items.
* Clicking on cancel should make the form go away, and return the table to normal mode.
* Clicking on the primary action button should cause that action to be completed. A notification should
  be triggered to any registered listeners. In the demo page, a notification box should appear.

Query Trail
------------

Actions which change the state of the query which the table represents should lead to a
new state being added to the trail. Each time this happens, this actions should be undo-able.
* Initially the query-trail should be invisible, as there is nothing to undo.
* when a change has been made, the trail should become visible, offering a simple `undo` action,
  as well as the ability to see information about the prior states.
* Each prior state should include a meaningful description, and a count of the number of rows
  in the table at that time. The user should also be able to compare the structure of two states
  to see what changed (see the columns, and filters and joins).
* The user should be able to revert the query to the immediate prior state by clicking `undo`.
* The user should be able to revert the query to any prior state by opening the list
  of prior states and clicking on the revert button next to that state
* The revert button next to the current state should be disabled.

Formatters
-----------

Cells may have their values formatted. This may apply to individual values, or it may 
produce a composite value composed of the sum of information in different columns.
* Values to be formatted include
  - All `id` attributes of objects, if a formatter is configured.
  - Any attribute of an object, if its class, or any of its parent classes is configured to
    format on `Class.*`.
  - Any attribute explicitly configured to be formatted.
* If a cell is formatted, and it is a composite value, then the composite value should appear only
  once in the table, replacing the columns that contain the data used to construct it.
* Any specific configured style should be applied.

Object Summaries
------------------

Each object may be previewed in an object summary. An object summary
* Should not obscure the cell that it it linked to
* Should not extend beyond the bounds of the table, if it can be contained within it.
* Indicate which cell it is linked to
* Indicate the actual type of the object
* Disappear when another element is clicked on.
* Display the fields configured to summarise that type of object
* Display a summary relevant to the specific type of the object, not that of the column's type.
* Show the fields in a predictable and consistent order (such as alphabetical).
* Have appropriate styling appied semantically to the various fields (formatting numbers
  as numbers, identifiers as identifiers, text as text).
* Hide long text fields, but offer to show them if desired.
* Display counts of related collections, if they have been configured.


