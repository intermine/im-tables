define 'table/models/page', ->

  # A representation of a page.
  class Page
      constructor: (@start, @size) ->
      end: -> @start + @size
      all: -> !@size
      toString: () -> "Page(#{ @start}, #{ @size })"
