_ = require 'underscore'
$ = require 'jquery'

# Use a post request to open a new window.
exports.openWindowWithPost = (uri, name, params, windowName) ->
  windowName ?= "someNonExistantPathToSomeWhere"
  form = $ """
      <form style="display;none" method="POST" action="#{ uri }" 
            target="#{ name }#{ new Date().getTime() }">
  """

  addInput = (k, v) ->
    input = $("""<input name="#{ k }" type="hidden">""")
    form.append(input)
    input.val(v)

  for k, v of params then do (k, v) ->
    if _.isArray v
      addInput k, v_ for v_ in v
    else
      addInput k, v

  form.appendTo 'body'
  w = window.open(windowName, name)
  form.submit()
  form.remove()
  w.close()

