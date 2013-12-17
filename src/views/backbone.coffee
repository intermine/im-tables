Backbone = require 'backbone'

$ = require 'jquery'
_ = require 'underscore'

class InterMineView extends Backbone.View

  make: (elemName, attrs, content) ->
    el = document.createElement(elemName)
    $el = $ el
    if attrs?
      for name, value of attrs
        if name is 'class'
          $el.addClass(value)
        else
          $el.attr name, value
    if content?
      if _.isArray(content)
        $el.append(x) for x in content
      else
        $el.append content

    el

module.exports = InterMineView

