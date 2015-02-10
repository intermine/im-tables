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
    m = @model
    @toggles.forEach (t) ->
      switch t.type
        when 'bool'
          e["click .#{ t.attr } .btn-on"] = -> m.set t.attr, true
          e["click .#{ t.attr } .btn-off"] = -> m.set t.attr, false
        when 'enum'
          e["click .#{ t.attr } .btn-unset"] = -> m.set t.attr, null
          t.opts.forEach (opt) ->
            ename = "click .#{ toCssClass t.attr } .btn-#{ toCssClass opt }"
            handler = -> m.set t.attr, opt
            e[ename] = handler

    return e

  template: _.template """
    <% _.each(toggles, function (t) { %>
      <div class="row <%- toCssClass(t.attr) %>">
        <div class="col-md-3"><label><%- t.attr %></label></div>
        <div class="col-md-9">
          <div class="btn-group btn-group-justified" role="group">
            <% if (t.type === 'bool') { %>
              <div class="btn-group" role="group">
                <button type="button"
                  class="btn btn-on btn-default<%= model[t.attr] ? ' active' : void 0 %>">
                  on
                </button>
              </div>
              <div class="btn-group" role="group">
                <button type="button"
                  class="btn btn-off btn-default<%= !model[t.attr] ? ' active' : void 0 %>">
                  off
                </button>
              </div>
            <% } else if (t.type === 'enum') { %>
              <% t.opts.forEach(function(opt) { %>
                <div class="btn-group" role="group">
                  <button type="button"
                    class="btn btn-<%- toCssClass(opt) %> btn-default<%= model[t.attr] === opt ? ' active' : void 0 %>">
                    <%- opt %>
                  </button>
                </div>
              <% }); %>
              <div class="btn-group" role="group">
                <button type="button"
                  class="btn btn-unset btn-default<%= model[t.attr] == null ? ' active' : void 0 %>">
                  <i>unset</i>
                </button>
              </div>
            <% } %>
          </div>
        </div>
      </div>
    <% }); %>
  """

