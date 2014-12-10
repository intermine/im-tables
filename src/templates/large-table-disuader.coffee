# FIXME - make this work by returning a Model
Icons = require '../icons'
# FIXME - make this work by returning a Model
Messages = require '../messages'
_ = require 'underscore'

TEMPL = _.template """
  <div class="modal im-page-size-sanity-check">
    <div class="modal-header">
      <h3>
        <%= size %> rows - are you sure?
      </h3>
    </div>
    <div class="modal-body">
      <p>
        You have requested a very large table size (<%= size %>). Your
        browser may struggle to render such a large table,
        and the page could become unresponsive. It
        will be very difficult for you to read the whole table
        in the page. We suggest the following alternatives:
      </p>
      <ul>
        <li>
            <p>
              If you are looking for something specific, you can use the
              <span class="label label-info">filtering tools</span>
              to narrow down the result set. Then you 
              might be able to fit the items you are interested in in a
              single page.
            </p>
            <button class="btn im-alternative-action add-filter-dialogue">
              <i class="<%= icons.Filter %>"></i>
              Add a new filter.
            </button>
          </li>
          <li>
            <p>
              If you want to see all the data, you can page 
              <span class="label label-info">
                <i class="icon-chevron-left"></i>
                backwards
              </span>
              and 
              <span class="label label-info">
                forwards
                <i class="icon-chevron-right"></i>
              </span>
              through the results.
            </p>
            <div class="btn-group">
              <a class="btn im-alternative-action page-backwards" href="#">
                <i class="icon-chevron-left"></i>
                go one page back
              </a>
              <a class="btn im-alternative-action page-forwards" href="#">
                go one page forward
                <i class="icon-chevron-right"></i>
              </a>
            </div>
          </li>
          <li>
              <p>
                  If you want to get and save the results, we suggest
                  <span class="label label-info">downloading</span>
                  the results in a format that suits you. 
              <p>
              <button class="btn im-alternative-action download-menu">
                  <i class="<%= icons.Export %>"></i>
                  Open the download menu.
              </buttn>
          </li>
      </ul>
    </div>
    <div class="modal-footer">
        <button class="btn btn-primary pull-right">
            <%- messages.getText('largetable.ok', {size: size}) %>
        </button>
        <button class="btn pull-left im-alternative-action">
            <%- messages.getText('largetable.abort') %>
        </button>
    </div>
  </div>
"""

module.exports = LargeTableDisuader = (data) ->
  TEMPL _.extend {messages: Messages, icons: Icons.toJSON()}, data

