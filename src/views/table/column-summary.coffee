_ = require 'underscore'

FacetView = require '../facets/facet-view'
PathModel = require '../../models/path'
{ignore} = require '../../utils/events'

NO_QUERY = 'No query in call to new DropDownColumnSummary'
BAD_MODEL = 'No PathModel in call to new DropDownColumnSummary'

# Thin wrapper that converts from the ColumnHeader calling convention
# of {query :: Query, model :: HeaderModel} to the FacetView constructor
# of {query :: Query, view :: PathInfo}.
module.exports = class DropDownColumnSummary extends FacetView

  className: -> "#{ super } im-dropdown-summary"

  constructor: ({query, model}) ->
    throw new Error(NO_QUERY) unless query
    throw new Error(BAD_MODEL) unless model instanceof PathModel
    super {query, view: model.pathInfo()}

  events: -> _.extend super, click: ignore

  postRender: ->
    super
    # there is one situation where this view is mounted, not appended.
    @$el.addClass @className()
