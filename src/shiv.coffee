# Set of things we want to be there. Insert if absent.

unless Array::filter?
    Array::filter = (test) ->
        x for x in this when test x

unless Array::map?
    Array::map = (transform) ->
        transform x for x in this

unless Array::indexOf? # Not present in ie8
  Array::indexOf = (elem) ->
    for x, i in this
      return i if x is elem

# In case $ is not jQuery, treat it as such in the lexical scope of this library.
$ = jQuery

# Temporary fix for the lack of make in recent backbone

unless Backbone.View::make?
  Backbone.View::make = (elemName, attrs, content) ->
    el = document.createElement(elemName)
    $el = $(el)
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

