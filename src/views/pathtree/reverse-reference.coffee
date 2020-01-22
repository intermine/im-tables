Icons = require '../../icons'

Reference = require './reference'

module.exports = class ReverseReference extends Reference

  className: 'im-reverse-reference'

  getData: ->
    d = super
    d.icon += " " + Icons.icon('ReverseRef')
    return d

  handleClick: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @$el.tooltip 'hide'

  render: ->
    super
    @$el.attr(title: "Refers back to #{ @path.getParent().getParent() }").tooltip()
    this

