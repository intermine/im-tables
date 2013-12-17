###
 * ===========================================================
 * bootstrap-popover.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#popovers
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
 * ===========================================================
###

Tooltip = require './bootstrap-tooltip'
_ = require 'underscore'

class Popover extends Tooltip

  constructor: (element, options = {}) ->
    @init 'popover', element, options

  setContent: ->
    $tip = @tip()
    title = @getTitle()
    content = @getContent()

    meth = if @options.html then 'html' else 'text'

    $tip.find('.popover-title')[meth] title
    $tip.find('.popover-content')[meth] content

    $tip.removeClass 'fade top bottom left right in'

  hasContent: -> @getTitle() or @getContent()

  getContent: ->
    $e = @$element
    o = @options
    
    o.content?.call?($e[0]) or o.content or $e.data 'content'

  tip: -> @$tip ?= $ @options.template

  destroy: ->
    @hide().$element.off('.' + @type).removeData(@type)

Popover.defaults =
  placement: 'right'
  trigger: 'click'
  content: ''
  template: """
    <div class="popover">
      <div class="arrow"></div>
      <h3 class="popover-title">
      </h3>
      <div class="popover-content"></div>
    </div>
  """

module.exports = Popover
