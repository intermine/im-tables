define 'html/code-gen', ->
  f = _.template """
    <div class="btn-group">
        <a class="btn btn-action">
            <i class="<%= __script_icon %>"></i>
            <span class="im-only-widescreen">Get</span>
            <span class="im-code-lang hidden-tablet"></span>
            <span class="hidden-tablet">Code</span>
        </a>
        <a class="btn dropdown-toggle" data-toggle="dropdown">
            <span class="caret"></span>
        </a>
        <ul class="dropdown-menu">
            <% _(langs).each(function(lang) { %>
              <li>
                <a data-lang="<%= lang.extension %>">
                    <i class="icon-<%= lang.extension %>"></i>
                    <%= lang.name %>
                </a>
              </li>
            <% }); %>
        </ul>
    </div>
    <div class="modal">
        <div class="modal-header">
            <a class="close im-closer" data-dismiss="modal">close</a>
            <h3>Generated <span class="im-code-lang"></span> Code</h3>
        </div>
        <div class="modal-body">
            <pre class="im-generated-code prettyprint linenums">
            </pre>
        </div>
        <div class="modal-footer">
            <a class="btn btn-save"><i class="<%= __file_icon %>"></i>Save</a>
            <a data-dismiss="modal" class="btn im-closer">Close</a>
        </div>
    </div>
  """
  
  (data) ->
    data.__script_icon = intermine.icons.Script
    data.__file_icon = intermine.icons.File
    f data
