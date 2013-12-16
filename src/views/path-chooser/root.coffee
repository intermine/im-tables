Attribute = require './attribute'

class exports.RootClass extends Attribute

  className: 'im-rootclass'

  initialize: (@query, @cd, @evts, @multiSelect) ->
      super(@query, @query.getPathInfo(@cd.name), 0, @evts, (() -> false), @multiSelect)

  template: _.template """
    <a>
      <i class="icon-stop"></i>
      <span><%- name %></span>
    </a>
  """

