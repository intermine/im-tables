# Mix-In for views that need to do paging.
# Requires this.model :: Model with the structure {size, start, count}
#
exports.getMaxPage = () ->
  {count, size} = @model.toJSON()
  correction = if count % size is 0 then 0 else 1
  Math.floor(count / size) + correction

exports.goTo = (start) ->
  console.debug 'Going to', start
  @model.set start: start

# Go to a 1-indexed page.
exports.goToPage = (page) -> @model.set start: ((page - 1) * @model.get('size'))

exports.goBack = (pages) ->
  {start, size} = @model.toJSON()
  @goTo Math.max 0, start - (pages * size)

exports.goForward = (pages) ->
  {start, size} = @model.toJSON()
  @goTo Math.min @getMaxPage() * size, start + (pages * size)
