###
 * ===========================================================
 * bootstrap-tooltip.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#tooltips
 * Inspired by the original jQuery.tipsy by Jason Frame
 * ===========================================================
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
 * ==========================================================
###

$ = require 'jquery'
_ = require 'underscore'

class Tooltip

  constructor: (element, options = {}) ->
    @init 'tooltip', element, options

  init: (@type, elementOrSelector, options) ->
    @$element = $ elementOrSelector
    @options = @getOptions options

    @enabled = true

    triggers = @options.trigger.split(' ')
    sel = @options.selector

    for trigger in triggers
      if trigger is 'click'
        @$element.on "click.#{ @type }", sel, $.proxy(@toggle, @)
      else if trigger isnt 'manual'
        isHover = trigger is 'hover'
        eventIn = if isHover then 'mouseenter' else 'focus'
        eventOut = if isHover then 'mouseleave' else 'blur'
        @$element.on "#{ eventIn }.#{ @type }", sel, $.proxy(@enter, @)
        @$element.on "#{ eventOut}.#{ @type }", sel, $.proxy(@leave, @)

    if sel
      @_options = _.extend {}, @options, trigger: 'manual', selector: ''
    else
      @fixTitle()

  getOptions: (o) ->
    options = _.extend {}, @constructor.defaults, @$element.data(), o

    if (d = options.delay) and typeof d is 'number'
      options.delay = show: d, hide: d

    return options

  enter: (evt) ->
    delay = @options.delay?.show
    return @show() unless delay

    clearTimeout(@timeout)
    @hoverState = 'in'
    @timeout = setTimeout (=> @show() if @hoverState is 'in'), delay

  leave: (evt) ->
    delay = @options.delay?.hide
    return @hide() unless delay

    clearTimeout @timeout
    @hoverState = 'out'
    @timeout = setTimeout (=> @hide() if @hoverState is 'out'), delay

  show: ->
    e = $.Event 'show'

    return unless ( @enabled and @hasContent() )

    @$element.trigger e
    return if e.isDefaultPrevented()
    $tip = @tip()
    @setContent()

    if @options.animation
      $tip.addClass 'fade'

    placement = (@options.placement?.call?(@, $tip[0], @$element[0]) or @options.placement)

    $tip.detach()
        .css(top: 0, left: 0, display: 'block')

    if @options.container
      $tip.appendTo @options.container
    else
      $tip.insertAfter(@$element)

    {top, height, left, width} = @getPosition()

    actualWidth = $tip[0].offsetWidth
    actualHeight = $tip[0].offsetHeight

    tp = switch placement
      when 'bottom' then do ->
        top: top + height,
        left: left + (width * 0.5) - (actualWidth * 0.5)
      when 'top' then do ->
        top: top - actualHeight,
        left: left + (width * 0.5) - (actualWidth * 0.5)
      when 'left' then do ->
        top: top + (height * 0.5) - (actualHeight * 0.5),
        left: left - actualWidth
      when 'right' then do ->
        top: top + (height * 0.5) - (actualHeight * 0.5),
        left: left + width

    @applyPlacement tp, placement
    @$element.trigger 'shown'

  applyPlacement: (offset, placement) ->

    $tip = @tip()

    width = $tip[0].offsetWidth
    height = $tip[0].offsetHeight

    $tip.offset(offset)
        .addClass(placement)
        .addClass('in')

    actualWidth = $tip[0].offsetWidth
    actualHeight = $tip[0].offsetHeight

    if placement is 'top' and actualWidth isnt height
      offset.top = offset.top + height - actualHeight
      replace = true

    if placement in ['bottom', 'top']
      delta = 0

      if offset.left < 0
        delta = offset.left * -2
        offset.left = 0
        $tip.offset(offset)
        actualWidth = $tip[0].offsetWidth
        actualHeight = $tip[0].offsetHeight

      @replaceArrow(delta - width + actualWidth, actualWidth, 'left')
    else
      @replaceArrow(actualHeight - height, actualHeight, 'top')

    $tip.offset(offset) if replace

  replaceArrow: (delta, dimension, position) ->
    @arrow().css position, if delta then "#{ 50 * (1 - delta / dimension) }%" else ''

  setContent: ->
    $tip = @tip()
    title = @getTitle()

    $tip.find('.tooltip-inner')[if @options.html then 'html' else 'text'] title
    $tip.removeClass 'fade in top bottom left right'

  hide: ->
    $tip = @tip()
    e = $.Event 'hide'

    @$element.trigger e
    return if e.isDefaultPrevented()

    $tip.removeClass('in')

    if $.support.transition and $tip.hasClass 'fade'
      timeout = setTimeout (-> $tip.off($.support.transition.end).detach()), 500
      $tip.one $.support.transition.end, ->
        clearTimeout timeout
        $tip.detach()
    else
      $tip.detach()

    @$element.trigger 'hidden'

    @

  fixTitle: ->
    $e = @$element
    if @$e.attr('title') or typeof $e.data('original-title') isnt 'string'
      $e.data('title', $e.attr('title') or '').attr('title', '')

  hasContent: -> @getTitle()

  getPosition: ->
    el = @$element[0]
    bounds = el.getBoundingClientRect?() ? {width: el.offsetWidth, height: el.offsetHeight}
    _.extend {}, bounds, @$element.offset()

  getTitle: ->
    $e = @$element
    $e.data('original-title') or @options.title?.call?($e[0]) or @options.title
    
  tip: -> @$tip ?= $ @options.template

  arrow: -> @$arrow ?= @tip().find('.tooltip-arrow')

  validate: ->
    unless @$element[0].parentNode
      @hide()
      @$element = null
      @options = null

  enable: -> @enabled = true

  disable: -> @enabled = false

  toggleEnabled: -> @enabled = not @enabled

  toggle: (evt) ->
    if @tip.hasClass('in')
      @hide()
    else
      @show()

  destroy: ->
    @hide().$element.off('.' + @type).removeData(@type)

Tooltip.defaults =
  animation: 'true'
  placement: 'top'
  selector: false
  trigger: 'hover focus'
  title: ''
  delay: 0
  html: false
  container: false
  template: """
    <div class="tooltip">
      <div class="tooltip-arrow"></div>
      <div class="tooltip-inner"></div>
    </div>
  """

module.exports = Tooltip
