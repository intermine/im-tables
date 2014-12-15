jQuery = $ = require 'jquery'

# Install jQuery on Backbone
Backbone = require 'backbone'
Backbone.$ = jQuery

# Ugly, since we leak jQuery, but only for the duration of this call
oldjq = global.jQuery
global.jQuery = $ # Yes, bootstrap *requires* jQuery to be global
# jQuery should now be available to bootstrap to attach.
require 'bootstrap' # Extend our jQuery with bootstrappy-goodness.
require 'typeahead.js' # Load the typeahead library.
require 'jquery-ui/slider' # Loading jquery-ui components.
# Restore previous state.
if oldjq?
  global.jQuery = oldjq
else
  delete global.jQuery

# Make dropdowns trigger events on toggle
oldToggle = $.fn.dropdown.Constructor.prototype.toggle
$.fn.dropdown.Constructor.prototype.toggle = (e) ->
  oldToggle.call(this, e)
  $(this).trigger('dropdown:toggle', $(this).closest('.dropdown').hasClass('open'))
  false

