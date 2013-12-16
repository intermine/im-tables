_ = require 'underscore'

icons = require '../../icons'

{Reference} = require './reference'

class exports.ReverseReference extends Reference

    template: _.template """<a href="#">
          <i class="#{ icons.ReverseRef } im-has-fields"></i>
          <span><%- name %></span>
        </a>
        """

    toggleFields: () -> # no-op

    handleClick: (e) -> 
      e.preventDefault()
      e.stopPropagation()
      @$el.tooltip 'hide'

    render: () ->
        super()
        @$el.attr(title: "Refers back to #{ @path.getParent().getParent() }").tooltip()
        this

