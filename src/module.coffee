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

scope = (path, code = (() ->), overwrite = false) ->
    parts = path.split "."
    ns = root
    for part in parts
        ns = if ns[part] then ns[part] else (ns[part] = {})
    exporting = (cls) ->
        ns[cls.name] = cls
    if _.isFunction code
        code(exporting)
    else
        for name, value of code
            ns[ name ] = value
    return ns



