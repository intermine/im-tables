# Ugly, since we leak jQuery, but only for the duration of this call
oldjq = global.jQuery

jQuery = $ = require 'jquery'

# Install jQuery on Backbone
Backbone = require 'backbone'
Backbone.$ = jQuery

global.jQuery = $ # Yes, bootstrap *requires* jQuery to be global
# jQuery should now be available to bootstrap to attach.
require 'bootstrap' # Extend our jQuery with bootstrappy-goodness.
require 'typeahead.js' # Load the typeahead library.
# Load jquery-ui components.
require 'jquery-ui/slider'
require 'jquery-ui/draggable'
require 'jquery-ui/droppable'
require 'jquery-ui/sortable'
# Restore previous state.
if oldjq?
  global.jQuery = oldjq
else
  delete global.jQuery
