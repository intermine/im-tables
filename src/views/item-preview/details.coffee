Templates = require '../../templates'
CoreView = require '../../core-view'
{ignore} = require '../../utils/events'

ITEMS = Templates.template 'cell-preview-items'
REFERENCE = Templates.template 'cell-preview-reference'
ATTR = Templates.template 'cell-preview-attribute'

module.exports = class ItemDetails extends CoreView

  tagName: 'table'

  className: 'im-item-details table table-condensed table-bordered'

  template: ITEMS

  collectionEvents: ->
    sort: @reRender
    add: @addDetail

  events: ->
    'click .im-too-long': @revealLongField

  postRender: -> @collection.each (details) => @addDetail details

  addDetail: (details) ->
    t = if ('ATTR' is details.get 'fieldType') then ATTR else REFERENCE
    @$el.append t details.toJSON()

  revealLongField: (e) ->
    ignore e
    $tooLong = @$ '.im-too-long'
    $overSpill = @$ '.im-overspill'
    $tooLong.remove()
    $overSpill.slideDown 250

