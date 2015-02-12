# Construct the index of which paths should be skipped when rendering a row of cells.
# If the headers are supplied they will be adjusted (assuming they are a PathCollection)
# by removing headers for the skipped paths and lifting the headers for the skipper
module.exports = (cells, headers) ->
  skipped = {}

  # Mark cells we are going to skip, and fix the headers as we go about it.
  for c in cells when c.formatter?.replaces?
    n = c.model.get('node').toString()
    col = c.model.get('column')
    p = col.toString()

    # The following code is not needed in the main table.
    if headers? and col.isAttribute() and c.formatter.replaces.length > 1
      # Swap out the current header for its parent.
      hi = headers.indexOf headers.get p
      headers.remove p
      parent = col.getParent()
      added = headers.add parent, at: hi
      added.set replaces: c.formatter.replaces.map (r) -> parent.append r

    for rp in (c.formatter.replaces.map (r) -> n + '.' + r) when rp isnt p
      skipped[rp] = true
      headers?.remove rp # remove the header for the skipped path.

  return skipped
