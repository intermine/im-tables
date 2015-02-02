createColumns = require './create-columns'
isKeyField = require './is-key-field'
getReplacedTest = require './get-replaced-test'
Formatting = require '../formatting'

# We can use a formatter if it hasn't been blacklisted.
#:: Collection -> Function -> bool
notBanned = (blacklist) -> (fmtr) -> not blacklist.any (b) -> fmtr is b.get('formatter')

#:: Function<a, b> -> Function<b, bool> -> b?
returnIfOK = (f) -> (test) -> (x) ->
  r = f x
  if test r then r else null

# Add an `index` property to each object, recording its position in the array.
#:: [Object] -> ()
index = (xs) -> for x, i in xs
  x.index = i

# Calculate the headers based on the views in the query.
# For this we need the class keys.
#
# It should be noted that this is both a rather inefficient way
# to do this (we loop over the columns multiple times), but also
# that the set is very small (the view list cannot in any practical
# sense get huge), so it is very unlikely to become a bottleneck.
#
# :: (Query, Collection) -> Promise
module.exports = (query, banList) -> query.fetchClassKeys().then (classKeys) ->
  # A function that tests a path to see if it is a key field.
  keyField = isKeyField classKeys
  # This holds a mapping from query views to the column that replaces them due to
  # formatting only.
  replacedBy = {}
  # This holds a mapping from the replaced path to the column that replaces it,
  # including replacements from sub-tables.
  explicitReplacements = {}
  # both get a formatter, and check we can use it.
  getFormatter = returnIfOK Formatting.getFormatter, notBanned banList

  # Create the columns :: [{path :: PathInfo, replaces :: [PathInfo]}]
  cols = createColumns query

  # Find formatters for the attribute columns (i.e. not the outer-joined
  # collections) and if those formatters specify which columns they replace,
  # add those paths to the replacement info for that column.
  # The replacement info is specified as an array of headless paths (e.g:
  # ['start', 'end', 'locatedOn.primaryIdentifier']). As we do this, record
  # which was the first column encountered that replaces each given column.
  for col in cols when col.path.isAttribute() and fmtr = getFormatter col.path
    col.isFormatted = true
    col.formatter = fmtr
    parent = col.path.getParent()
    for replaced in (fmtr.replaces ? [])
      subPath = "#{ parent }.#{ replaced }"
      # That path is replaced by this column.
      replacedBy[subPath] ?= col
      # This column replaces that subpath if the subpath is in the view.
      col.replaces.push(query.makePath subPath) if subPath in query.views

  # Build the explicit replacement information, indexing which column replaces which
  # view path either due to formatting or due to outer-join sub-tables, where
  # replaces is the list of query.views that this column replaces.
  for col in cols
    for replaced in col.replaces
      explicitReplacements[replaced] = col

  # Define a filter that weeds out view paths that are in fact handled by the
  # formatter registered on another column. This means that the final list of
  # headers can in fact be shorter than the actual view, collapsing two or more
  # columns down onto a single column.
  isReplaced = getReplacedTest replacedBy, explicitReplacements

  # OK, now filter out the columns that have been replaced.
  newHeaders = for col in cols when not isReplaced col
    if col.isFormatted
      # Ensure that the column.replaces info contains the column's path.
      col.replaces.push col.path unless col.path in col.replaces
      # Raise the path to its parent if it is a key field, or it is composed.
      col.path = col.path.getParent() if (keyField col.path) or (col.replaces.length > 1)
    col

  # Apply the correct index to each header.
  index newHeaders

  return newHeaders

