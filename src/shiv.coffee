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

# Make dropdowns trigger events on toggle
do ($ = jQuery) ->
  oldToggle = $.fn.dropdown.Constructor.prototype.toggle
  $.fn.dropdown.Constructor.prototype.toggle = (e) ->
    oldToggle.call(this, e)
    $(this).trigger('toggle', $(this).closest('.dropdown').hasClass('open'))
    false

# Hack to fix tooltip positioning for SVG.
# This should continue to work with future versions,
# as it basically just makes the positioning alogrithm
# compatible with SVG. I know this is fixed in bootstrap 2.3.0+,
# but there is no programmatic version of bootstrap available.
do ($ = jQuery) ->
  oldPos = $.fn.tooltip.Constructor.prototype.getPosition
  $.fn.tooltip.Constructor.prototype.getPosition = ->
    ret = oldPos.apply(@, arguments)
    el = @$element[0]
    if (not ret.width and not ret.height and 'http://www.w3.org/2000/svg' is el.namespaceURI)
      {width, height} = (el.getBoundingClientRect?() ? el.getBBox())
      return $.extend ret, {width, height}
    else
      return ret
