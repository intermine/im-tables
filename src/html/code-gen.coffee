define 'html/code-gen', -> _.template """
  <div class="btn-group">
      <a class="btn btn-action" href="#">
          <i class="#{ intermine.icons.Script }"></i>
          <span class="im-only-widescreen">Get</span>
          <span class="im-code-lang hidden-tablet"></span>
          <span class="hidden-tablet">Code</span>
      </a>
      <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
          <span class="caret"></span>
      </a>
      <ul class="dropdown-menu">
          <% _(langs).each(function(lang) { %>
            <li>
              <a href="#" data-lang="<%= lang.extension %>">
                  <i class="icon-<%= lang.extension %>"></i>
                  <%= lang.name %>
              </a>
            </li>
          <% }); %>
      </ul>
  </div>
  <div class="modal">
      <div class="modal-header">
          <a class="close" data-dismiss="modal">close</a>
          <h3>Generated <span class="im-code-lang"></span> Code</h3>
      </div>
      <div class="modal-body">
          <pre class="im-generated-code prettyprint linenums">
          </pre>
      </div>
      <div class="modal-footer">
          <a href="#" class="btn btn-save"><i class="icon-file"></i>Save</a>
          <a href="#" data-dismiss="modal" class="btn">Close</a>
      </div>
  </div>
"""
