jQuery = $ = require 'jquery'

# Install jQuery on Backbone
Backbone = require 'backbone'
Backbone.$ = jQuery

oldjq = global.jQuery
# Ugly, since we leak jQuery, but only for the duration of this call
global.jQuery = $ # Yes, bootstrap *requires* jQuery to be global
# jQuery should now be available to bootstrap to attach.
require 'bootstrap' # Extend our jQuery with bootstrappy-goodness.
# Restore previous state.
if oldjq?
  global.jQuery = oldjq
else
  delete global.jQuery

# Make dropdowns trigger events on toggle
do ($ = jQuery) ->
  oldToggle = $.fn.dropdown.Constructor.prototype.toggle
  $.fn.dropdown.Constructor.prototype.toggle = (e) ->
    oldToggle.call(this, e)
    $(this).trigger('toggle', $(this).closest('.dropdown').hasClass('open'))
    false

