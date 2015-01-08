scope 'intermine.snippets.facets', {
  OnlyOne: _.template """
      <div class="alert alert-info im-all-same">
        All <%= count %> values are the same: <strong><%= item %></strong>
      </div>
    """
}

do ->

  ##----------------
  ## Returns a fn to calculate a point Z(x), 
  ## the Probability Density Function, on any normal curve. 
  ## This is the height of the point ON the normal curve.
  ## For values on the Standard Normal Curve, call with Mean = 0, StdDev = 1.
  NormalCurve = (mean, stdev) ->
    (x) ->
      a = x - mean
      Math.exp(-(a * a) / (2 * stdev * stdev)) / (Math.sqrt(2 * Math.PI) * stdev)

  Int = (x) -> parseInt(x, 10)

  numeric = (x) -> +x

  MORE_FACETS_HTML = """
    <i class="icon-plus-sign pull-right" title="Showing top ten. Click to see all values"></i>
  """
