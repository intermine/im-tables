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

scope = (path, code = ->) ->
    parts = path.split "."
    ns = root
    for part in parts
        ns = if ns[part] then ns[part] else (ns[part] = {})
    exporting = (cls) ->
        ns[cls.name] = cls
    code(exporting)
    return ns



