_ = require 'underscore'

module.exports = _.template """
  <div class="alert alert-info im-all-same">
      All <%= count %> values are the same: <strong><%= item %></strong>
  </div>
"""
