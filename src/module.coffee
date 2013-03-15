root = exports ? this

unless root.console
    root.console =
        log: ->
        debug: ->
        error: ->

stope = (f) -> (e) ->
    e.stopPropagation()
    e.preventDefault()
    f(e)

# TODO, allow merging of nested things.
scope = (path, code = {}, overwrite = false) ->
    parts = path.split "."
    ns = root
    for part in parts
        ns = if ns[part]? then ns[part] else (ns[part] = {})

    for name, value of code
        # Update but do not overwrite values.
        if overwrite or not ns[name]?
            ns[ name ] = value
    return ns


pending_modules = {}
defined_modules = {}

check_pending = ->
  newDefs = 0
  for name, pending of pending_modules
    obj = pending()
    if obj?
      defined_modules[name] = obj
      delete pending_modules[name]
      newDefs++

  newDefs

define = (name, f) ->
  obj = f()
  if obj?
    defined_modules[name] = obj
  else
    pending_modules[name] = f
  check_pending()
  obj

using = (names..., f) -> () ->
  objs = (defined_modules[name] for name in names when name of defined_modules)
  if objs.length is names.length
    f objs...
  else
    null

get_pending = -> (name for name of pending_modules)

end_of_definitions = ->
  while check_pending() # Load all resolvable pending modules.
    1
  pending = get_pending()
  if pending.length
    throw new Error('The following modules have unmet dependencies: ' + pending + '. The following modules are defined: ' + (n for n of defined_modules))

# Export this out for others to use.
scope "intermine", {scope}, true



