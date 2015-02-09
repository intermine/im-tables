_ = require 'underscore'
CoreView = require 'imtables/core-view'

toCssClass = (x) -> x.replace /\./g, '-'

module.exports = class Toggles extends CoreView

  className: 'container'

  parameters: ['toggles']

  getData: ->
    toCssClass: toCssClass
    model: @model.pick(t.attr for t in @toggles)
    toggles: @toggles

  modelEvents: -> change: @reRender

  events: ->
    e = {}
    @toggles.forEach (t) ->
      if t.type is 'bool'
        e["click .#{ t.attr } .btn-on"] = -> @model.set t.attr, true
        e["click .#{ t.attr } .btn-off"] = -> @model.set t.attr, false
      else
        e["click .#{ t.attr } .btn-unset"] = -> @model.set t.attr, null
        t.opts.forEach (opt) ->
          e["click .#{ t.attr } .btn-#{ toCssClass opt }"] = -> @model.set t.attr, opt

    return e

  template: _.template """
    <% _.each(toggles, function (t) { %>
      <div class="row <%- t.attr %>">
        <div class="col-md-3"><label><%- t.attr %></label></div>
        <div class="col-md-9">
          <div class="btn-group" role="group">
            <% if (t.type === 'bool') { %>
              <button type="button"
                class="btn btn-on btn-default<%= model[t.attr] ? ' active' : void 0 %>">
                on
              </button>
              <button type="button"
                class="btn btn-off btn-default<%= !model[t.attr] ? ' active' : void 0 %>">
                off
              </button>
            <% } else { %>
              <% t.opts.forEach(function(opt) { %>
                <button type="button"
                  class="btn btn-<%- toCssClass(opt) %> btn-default<%= model[t.attr] === opt ? ' active' : void 0 %>">
                  <%- opt %>
                </button>
              <% }); %>
              <button type="button"
                class="btn btn-unset btn-default<%= model[t.attr] == null ? ' active' : void 0 %>">
                <i>unset</i>
              </button>
            <% } %>
          </div>
        </div>
      </div>
    <% }); %>
  """

