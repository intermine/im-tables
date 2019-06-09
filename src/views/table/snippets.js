/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
scope('intermine.snippets.table', {
  NoResults(query) { return _.template(`\
<tr>
  <td colspan="<%= views.length %>">
    <div class="im-no-results alert alert-info">
      <div <% if (revision === 0) { %> style="display:none;" <% } %> >
        ${ intermine.snippets.query.UndoButton }
      </div>
      <strong>NO RESULTS</strong>
      This query returned 0 results.
      <div style="clear:both"></div>
    </div>
  </td>
</tr>\
`, query); },
  // A function of the form ({count: i, first: i, last: i, roots: str}) -> str
  CountSummary: _.template(`\
    `
  ),
  Pagination: _.template(`\
    `
  )
}
);

scope('intermine.snippets.query', {
    UndoButton: `\
<button class="btn btn-primary pull-right">
  <i class="${ intermine.icons.Undo }"></i> undo
</button>\
`
});
