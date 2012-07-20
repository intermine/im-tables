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
    exporting = (cls) -> ns[cls.name] = cls
    if _.isFunction code
        code(exporting)
    else
        for name, value of code
            # Update but do not overwrite values.
            if overwrite or not ns[name]?
                ns[ name ] = value
    return ns

# Export this out for others to use.
scope "intermine", {scope: scope}, true



