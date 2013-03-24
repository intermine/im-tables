Release Testing
==================

Before each release, the following specification must be verified
by human testers. Any deviation from this spec is a bug, and should
be reported at [https://github.com/intermine/im-tables/issues.]()

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
    editing an existing constraint (see [editing filters][#editing-filters]).
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

Export
------

TODO

Column Headers
---------------

TODO


Result Cells
------------

TODO

List Management
----------------

TODO

Query Trail
------------

TODO


