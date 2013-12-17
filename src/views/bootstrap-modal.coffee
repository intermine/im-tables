###
 * bootstrap-modal.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#modals
 * =========================================================
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

class Modal

  constructor: (element, @options) ->
    _.defaults options, Modal.defaults
    @$element = $ element
    @$element.delegate('[data-dismiss="modal"]', 'click.dismiss.modal', => @hide())
    if @options.remote
      @$element.find('.modal-body').load(@options.remote)

  toggle: ->
    if @isShown
      @hide()
    else
      @show()

  show: ->

    e = $.Event 'show'

    @$element.trigger e
    return if @isShown or e.isDefaultPrevented()

    @isShown = true

    @escape()

    @backdrop =>
      canTransition = transition.supported and @$element.hasClass 'fade'

      unless @$element.parent().length
        @$element.appendTo document.body

      @$element.show()

      if canTransition
        @$element[0].offsetWidth # force reflow

      @$element.addClass('in')
               .attr('aria-hidden', false)

      @enforceFocus()

      if canTransition
        @$element.one transition.end, => @$element.focus().trigger('shown')
      else
        @$element.focus().trigger 'shown'

  hide: (evt) ->
    evt?.preventDefault?()

    e = $.Event 'hide'

    @$element.trigger e

    return if (not @isShown) or e.isDefaultPrevented()

    @isShown = false
    @escape()
    $(document).off('focusin.modal')

    @$element.removeClass('in')
             .attr('aria-hidden', true)

    if transition.supported and @$element.hasClass 'fade'
      @hideWithTransition()
    else
      @hideModal()

  enforceFocus: -> $(document).on 'focusin.modal', (e) =>
    if @$element[0] isnt e.target and not @$element.has(e.target).length
      @$element.focus()

  escape: ->
    if @isShown and @options.keyboard
      @$element.on 'keyup.dismiss.modal', (e) =>
        @hide() if e.which is 27 # ESC
    else if not @isShown
      @$element.off 'keyup.dismiss.modal'

  hideWithTransition: ->
    $e = @$element
    timeout = setTimeout (=> $e.off(transition.end); @hideModal()), 500
    @$element.one transition.end, =>
      clearTimeout timeout
      @hideModal()

  hideModal: ->
    @$element.hide()
    @backdrop =>
      @removeBackdrop()
      @$element.trigger 'hidden'

  removeBackdrop: ->
    @$backdrop?.remove()
    @$backdrop = null

  backdrop: (cb) ->
    animate = if @$element.hasClass('fade') then 'fade' else ''

    if @isShown and @options.backdrop

      doAnimate = transition.supported and animate
      @$backdrop = b = $ """<div class="modal-backdrop #{ animate }"/>"""
      b.appendTo document.body

      b.click if @options.backdrop is 'static' then (=> @$element[0].focus()) else (=> @hide())

      if doAnimate
        b[0].offsetWidth # force reflow

      b.addClass 'in'

      return unless cb?

      if doAnimate
        b.one transition.end, cb
      else
        cb()
    
    else if (not @isShown) and @$backdrop

      @$backdrop.removeClass 'in'
      if transition.supported and @$element.hasClass 'fade'
        @$backdrop.one transition.end, cb
      else
        cb()

    else if cb
      cb()

Modal.defaults =
  backdrop: true
  keyboard: true
  show: true

module.exports = Modal
