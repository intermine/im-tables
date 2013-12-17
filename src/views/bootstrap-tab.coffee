###
 * bootstrap-tab.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#tabs
 * ========================================================
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
_ = require 'underscore'

transition = require '../transition'

reflow = (jq) -> jq[0].offsetWidth

class Tab

  constructor: (element) ->
    @$element = $ element

  show: ->
    $ul = @$element.closest('ul:not(.dropdown-menu)')
    target = @$element.data 'target'

    unless target
      target = @$element.attr('href')?.replace /.*(?=#[^\s]*$)/, ''

    liParent = @$element.parent('li')
    return if liParent.hasClass 'active'

    previous = $ul.find('.active:last a')[0]

    e = $.Event 'show', relatedTarget: previous

    @$element.trigger e

    return if e.isDefaultPrevented()

    $target = $ target

    @activate liParent, $ul
    @activate $target, $target.parent(), =>
      @$element.trigger type: 'shown', relatedTarget: previous

  activate: (element, container, callback) ->
    $active = container.find('> .active')
    canTransition = callback and transition.supported and $active.hasClass 'fade'

    next = ->
      $active.removeClass('active')
             .find('> .dropdown-menu > .active')
             .removeClass('active')

      element.addClass('active')

      if canTransition
        reflow element
        element.addClass 'in'
      else
        element.removeClass 'fade'

      if element.parent('.dropdown-menu')
        element.closest('li.dropdown').addClass 'active'

      callback?()
    
    if canTransition
      $active.one(transition.end, next)
    else
      next()

    $active.removeClass 'in'

