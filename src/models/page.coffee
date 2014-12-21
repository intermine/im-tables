module.exports = class Page
  constructor: (@start, @size) ->
  end: -> @start + @size
  all: -> !@size
  toString: () -> "Page(#{ @start}, #{ @size })"
