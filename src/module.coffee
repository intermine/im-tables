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

# Declare here for visibility.
define = ->
using = ->
end_of_definitions = ->

do ->

  pending_modules = {}
  defined_modules = {}

  sweep_pending = ->
    newDefs = 0
    for name, pending of pending_modules
      obj = pending()
      if obj?
        defined_modules[name] = obj
        delete pending_modules[name]
        newDefs++
    newDefs

  define_pending_modules = -> 1 while sweep_pending()

  define = (name, f) ->
    if name of pending_modules or name of defined_modules
      throw new Error("Duplicate definition for #{ name }")
    pending_modules[name] = f
    define_pending_modules()
    null

  using = (names..., f) -> (eof = false) ->
    objs = (defined_modules[name] for name in names when name of defined_modules)
    if objs.length is names.length
      f objs...
    else if eof # report missing dependencies.
      (name for name in names when name not of defined_modules)
    else
      null

  end_of_definitions = -> # TODO, remove the need to check this here.
    pending = (name for name of pending_modules)
    if pending.length
      err = "The following modules have unmet dependencies"
      problems = ("#{ name } needs [#{ pending_modules[name] true }]" for name in pending)
      throw new Error("#{ err }: #{ problems.join ', ' }")

# Export this out for others to use.
scope "intermine", {scope}, true

