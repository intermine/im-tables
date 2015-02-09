_ = require 'underscore'
CoreView = require 'imtables/core-view'

module.exports = class Toggles extends CoreView

  className: 'container'

  parameters: ['toggles']

  getData: -> switches: @model.pick(@toggles), toggles: @toggles

  modelEvents: -> change: @reRender

  events: ->
    e = {}
    @toggles.forEach (t) ->
      e["click .#{ t } .btn-on"] = -> @model.set t, true
      e["click .#{ t } .btn-off"] = -> @model.set t, false
    return e

  template: _.template """
    <% _.each(toggles, function (t) { %>
      <div class="row <%- t %>">
        <div class="col-md-3"><label><%- t %></label></div>
        <div class="col-md-9">
          <div class="btn-group" role="group">
            <button type="button"
              class="btn btn-on btn-default<%= switches[t] ? ' active' : void 0 %>">
              on
            </button>
            <button type="button"
              class="btn btn-off btn-default<%= !switches[t] ? ' active' : void 0 %>">
              off
            </button>
          </div>
        </div>
      </div>
    <% }); %>
  """

