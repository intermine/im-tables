###
 * bootstrap-dropdown.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#dropdowns
 * ============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
###

$ = require 'jquery'

TOGGLE = '[data-toggle=dropdown]'

# Get the configured target parent, defaulting to the immediate DOM parent.
getParent = ($el) ->
  target = $el.data('target')

  unless target
    target = $el.attr 'href'
    target = target.replace(/.*(?=#[^\s]*$)/, '') if target? and /#/.test target

  $target = $ target if target?

  unless $target?.length
    $target = $el.parent()

  return $target

# Close all active menus.
clearMenus = -> $(TOGGLE).each -> getParent($ this).removeClass 'open'

class Dropdown

  constructor: (element) ->
    @$element = $el = $ element
    $el.on 'click.dropdown.data-api', @toggle
    $('html').on 'click.dropdown.data-api', ->
      $el.parent().removeClass 'open'
  
  toggle: ->
    $el = @$element ? $ this
    return if @$element.is('.disabled, :disabled')

    e = $.Event 'toggle'

    @$element.trigger e
    return if e.getDefaultPrevented()

    $parent = getParent(@$element)

    isActive = $parent.hasClass 'open'

    clearMenus()

    unless isActive
      $parent.toggleClass 'open'

    @$element.focus()

    @$element.trigger 'toggled'

    return false

  keydown: (e) ->
    kc = e.keyCode
    return if kc not in [38, 40, 27]

    $this = $ this

    e.preventDefault()
    e.stopPropagation()

    return if $this.is('.disabled, :disabled')

    $parent = getParent $this

    isActive = $parent.hasClass 'open'

    if (not isActive) or (isActive and kc is 27)
      $parent.find(toggle).focus() if e.which is 27
      return $this.click()

    $items = $ '[role=menu] li:not(.divider):visible a', $parent

    return unless $items.length

    index = $items.index($items.filter(':focus'))

    switch kc
      when 38 then index-- # up
      when 40 then index++ # down

    if not ~index
      index = 0

    $items.eq(index).focus()

# Apply to dropdown elements.
$(document)
  .on('click.dropdown.data-api', clearMenus)
  .on('click.dropdown.data-api', '.dropdown form', (e) -> e.stopPropagation())
  .on('click.dropdown-menu', (e) -> e.stopPropagation())
  .on('click.dropdown.data-api', TOGGLE, Dropdown::toggle)
  .on('keydown.dropdown.data-api', TOGGLE + ', [role=menu]', Dropdown::keydown)

module.exports = Dropdown

