_ = require 'underscore'

TEMPLATE_SETTINGS =
  variable: 'data' # Allows us to use sub-templates easily

module.exports = _.template("""
  <label class="im-con-overview">
    <a class="im-remove-constraint">
      <%= data.icons.icon('RemoveConstraint') %>
    </a>
    <% if (data.con.locked) { %>
      <a title="<%- data.messages.getText('conbuilder.NotEditable') %>">
        <%= data.icons.icon('Lock') %>
      </a>
    <% } %>
    <a class="im-edit"><%= data.icons.icon('Edit') %></a>
    <ol class="summary breadcrumb">
      <% _.each(data.summary, function (label) { %>
        <li>        
          <% if (label.type === 'extra') { %>
            <%- data.messages.getText('conbuilder.ExtraLabel') %>
          <% } %>
          <span class="label label-<%- label.type %>">
            <%- label.content %>
          </span>
        </li>
      <% }); %>
    </ol>
  </label>

  <fieldset class="im-constraint-options">
    <% if (data.con.op) { %>
      <select class="span4 form-control im-ops">
        <option><%- data.con.op %></option>
        <% data.otherOperators.forEach(function (op) { %>
          <option><%- op %></option>
        <% }); %>
      </select>
    <% } %>
    <div class="im-value-options">
      <%= data.valueTemplate(data) %>
    </div>
  </fieldset>

  <div class="btn-group im-con-buttons">
    <% data.buttons.forEach(function (b) { %>
      <button class="<%- b.classes %>">
        <%- data.messages.getText(b.key) %>
      </button>
    <% }); %>
  </div>

  <div class="alert alert-error <%= data.con.error ? '' : 'im-hidden' %>">
    <%= data.icons.icon('Error') %>
    <span class="im-conbuilder-error">
      <%- data.con.error %>
    </span>
  </div>
""", TEMPLATE_SETTINGS)

