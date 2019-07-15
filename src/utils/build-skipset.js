// Construct the index of which paths should be skipped when rendering a row of cells.
// If the headers are supplied they will be adjusted (assuming they are a PathCollection)
// by removing headers for the skipped paths and lifting the headers for the skipper
module.exports = function(cells, headers) {
  const skipped = {};

  // Mark cells we are going to skip, and fix the headers as we go about it.
  for (let c of Array.from(cells)) {
    if ((c.formatter != null ? c.formatter.replaces : undefined) != null) {
      var n = c.model.get('node').toString();
      const col = c.model.get('column');
      const p = col.toString();

      // The following code is not needed in the main table.
      if ((headers != null) && col.isAttribute() && (c.formatter.replaces.length > 1)) {
        // Swap out the current header for its parent.
        const hi = headers.indexOf(headers.get(p));
        headers.remove(p);
        var parent = col.getParent();
        const added = headers.add(parent, {at: hi});
        added.set({replaces: c.formatter.replaces.map(r => parent.append(r))});
      }

      if (!skipped[p]) {
        for (let rp of Array.from((c.formatter.replaces.map(r => n + '.' + r)))) {
          if (rp !== p) {
            skipped[rp] = true;
            if (headers != null) {
              headers.remove(rp);
            }
          }
        } // remove the header for the skipped path.
      }
    }
  }

  return skipped;
};
