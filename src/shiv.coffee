# Set of things we want to be there. Insert if absent.

unless Array::filter
    Array::filter = (test) ->
        x for x in this when test x

unless Array::map
    Array::map = (transform) ->
        transform x for x in this

# In case $ is not jQuery, treat it as such in the lexical scope of this library.
$ = jQuery

