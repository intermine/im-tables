do ->
  
  class DynamicPopover extends jQuery.fn.popover.Constructor

    constructor: (elem, opts) ->
      @init 'popover', elem, opts
      $(elem).data('popover', this)
      @tip().addClass opts.classes if opts?.classes

    # Always true, to prevent calling getContent() twice.
    hasContent: -> true

    getPlacement: ->
      if typeof @options.placement is 'function'
        @options.placement.call(this, @tip()[0], @$element[0])
      else
        @options.placement

    respectContainment: (offset, pos, placement) ->
      $tip = @tip()
      arrowOffset = {}

      actualWidth = $tip[0].offsetWidth
      actualHeight = $tip[0].offsetHeight

      $containment = @$element.closest(@options.containment)
      {top, left} = $containment.offset()
      height = $containment[0].offsetHeight
      bottom = top + height

      arrowHeight = $tip.find('.arrow')[0].offsetHeight
      arrowWidth = $tip.find('.arrow')[0].offsetWidth
      
      if actualHeight >= height
        $tip.find('.arrow').css({top: '', left: ''}) # Undo any previous changes.
        return # Cannot help here.

      if placement is 'right' or placement is 'left'
        if offset.top < top
          diff = top - offset.top
          offset.top += diff
          arrowOffset.top = offset.top + (pos.top - offset.top) + (pos.height / 2) - (arrowHeight / 2)
        else if offset.top + actualHeight > bottom
          diff = offset.top + actualHeight - bottom
          offset.top -= diff
          arrowOffset.top = offset.top + (pos.top - offset.top) + (pos.height / 2) - (arrowHeight / 2)
      else
        if offset.left < left
          diff = left - offset.left
          offset.left += diff
          arrowOffset.left = pos.left + ( pos.width / 2 ) - (arrowWidth / 2)
        

      if placement is 'right'
        offset.left += arrowWidth
      else if placement is 'top'
        offset.top -= arrowHeight
      else if placement is 'left'
        offset.left -= arrowWidth


      $tip.offset offset
      $tip.find('.arrow').offset arrowOffset

    applyPlacement: (offset, placement) ->
      $tip = @tip()
      $tip.removeClass('left right top bottom')
      super(offset, placement)

    reposition: ->
      pos = @getPosition()
      $tip = @tip()

      # Would love to not have to repeat this, but ho hum.
      actualWidth = $tip[0].offsetWidth
      actualHeight = $tip[0].offsetHeight

      placement = @getPlacement()

      tp = switch placement
        when 'bottom'
          {top: pos.top + pos.height, left: pos.left + pos.width / 2 - actualWidth / 2}
        when 'top'
          {top: pos.top - actualHeight, left: pos.left + pos.width / 2 - actualWidth / 2}
        when 'left'
          {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left - actualWidth}
        when 'right'
          {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left + pos.width}

      @applyPlacement(tp, placement)

      if @options.containment?
        @respectContainment(tp, pos, placement)

      @$element.trigger('repositioned')

  scope 'intermine.bootstrap', {DynamicPopover}







