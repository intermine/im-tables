scope 'intermine.snippets.table',
  NoResults: (query) -> _.template """
    <tr>
      <td colspan="<%= views.length %>">
        <div class="im-no-results alert alert-info">
          <div <% if (__changed === 0) { %> style="display:none;" <% } %> >
            #{ intermine.snippets.query.UndoButton }
          </div>
          <strong>NO RESULTS</strong>
          This query returned 0 results.
          <div style="clear:both"></div>
        </div>
      </td>
    </tr>
    """, query
  # A function of the form ({count: i, first: i, last: i, roots: str}) -> str
  CountSummary: _.template """
      <span class="hidden-phone">
      <span class="im-only-widescreen">Showing</span>
      <span>
        <% if (last == 0) { %>
            All
        <% } else { %>
            <%= first %> to <%= last %> of
        <% } %>
        <%= count %> <span class="visible-desktop"><%= roots %></span>
      </span>
      </span>
    """
  Pagination: """
      <div class="pagination pagination-right">
        <ul>
          <li title="Go to start">
            <a class="im-pagination-button" data-goto=start>&#x21e4;</a>
          </li>
          <li title="Go back five pages" class="visible-desktop">
            <a class="im-pagination-button" data-goto=fast-rewind>&#x219e;</a>
          </li>
          <li title="Go to previous page">
            <a class="im-pagination-button" data-goto=prev>&larr;</a>
          </li>
          <li class="im-current-page">
            <a data-goto=here  href="#">&hellip;</a>
            <form class="im-page-form input-append form form-horizontal" style="display:none;">
            <div class="control-group"></div>
          </form>
          </li>
          <li title="Go to next page">
            <a class="im-pagination-button" data-goto=next>&rarr;</a>
          </li>
          <li title="Go forward five pages" class="visible-desktop">
            <a class="im-pagination-button" data-goto=fast-forward>&#x21a0;</a>
          </li>
          <li title="Go to last page">
            <a class="im-pagination-button" data-goto=end>&#x21e5;</a>
          </li>
        </ul>
      </div>
    """

scope 'intermine.snippets.query', {
    UndoButton: '<button class="btn btn-primary pull-right"><i class="icon-undo"></i> undo</button>'
}
