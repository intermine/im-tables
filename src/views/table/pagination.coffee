SELECT_LIMIT = 200 # for more than 200 pages move to form

_ = require 'underscore'
fs = require 'fs'

View = require '../../core-view'
Paging = require './paging'

html = fs.readFileSync __dirname + '/../../templates/pagination.mtpl', 'utf8'

strip = (s) -> s.replace /\s+/g, ''

ensureNumber = (raw) ->
  if (typeof raw is 'string') then (parseInt (strip raw), 10) else raw

module.exports = class Pagination extends View
  
  @include Paging

  tagName: 'nav'

  className: 'im-table-pagination'

  RERENDER_EVENT: 'change:start change:count change:size'

  template: _.template html
  
  getData: ->
    {start, size, count} = @model.toJSON()
    max = @getMaxPage()
    data =
      max: max
      min: 1
      size: size
      currentPage: @getCurrentPage()
      gotoStart: (if start is 0 then 'disabled')
      goFiveBack: (if start < (5 * size) then 'disabled')
      goOneBack: (if start < size then 'disabled')
      gotoEnd: (if start >= (count - size) then 'disabled')
      goFiveForward: (if start >= (count - 6 * size) then 'disabled')
      goOneForward: (if start >= (count - size) then 'disabled')
      selected: (i) -> start is i * size
      useSelect: (max <= SELECT_LIMIT)

  postRender: -> @$('li').tooltip placement: 'top'

  events: ->
    'submit .im-page-form': 'pageFormSubmit'
    'click .im-current-page a': 'clickCurrentPage'
    'change .im-page-form select': 'goToChosenPage'
    'blur .im-page-form input': 'pageFormSubmit'
    'click .im-goto-start': => @goTo 0
    'click .im-goto-end': =>
      console.debug 'off to the end'
      @goTo (@getMaxPage() - 1) * @model.get('size')
    'click .im-go-back-5': => @goBack 5
    'click .im-go-back-1': => @goBack 1
    'click .im-go-fwd-5': => @goForward 5
    'click .im-go-fwd-1': => @goForward 1

  goToChosenPage: (e) ->
    start = ensureNumber @$(e.target).val()
    @goTo start

  clickCurrentPage: (e) ->
    size = @model.get 'size'
    total = @model.get 'count'
    return if size >= total
    @$(e.target).hide()
    @$('form').show().find('input').focus()

  pageFormSubmit: (e) ->
    e?.stopPropagation()
    e?.preventDefault()
    pageForm = @$('.im-page-form')
    input = @$('.im-page-form input')
    if input.size()
      destination = ensureNumber input[0].value
      if destination >= 1
        page = Math.min @getMaxPage(), destination
        @goTo (page - 1) * @model.get('size')
        @$('.im-current-page > a').show()
        pageForm.hide()
      else
        pageForm.find('.control-group').addClass 'error'
        inp.val null
