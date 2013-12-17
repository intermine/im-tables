_ = require 'underscore'

module.exports = _.template """
    <dd>
        <a href=#>
            <b class="im-facet-count pull-right">
                (<%= count %>)
            </b>
            <%= item %>
        </>
    </dd>
"""

