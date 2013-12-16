_ = require('underscore')

module.exports = _.template """
    <div class="alert alert-error">
      <p class="apology">Could not fetch summary</p>
      <pre><%- message %></pre>
    </div>
  """

