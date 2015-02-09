_ = require 'underscore'

FIELDS = ['name', 'vatNumber']
FETCHES = {}

getMissingData = (s, id) ->
  FETCHES[s.root + '#' + id] ?= s.findById('Company', id).then (r) -> _.pick r, FIELDS

hasData = (model) -> _.all FIELDS, (f) -> model.has f

module.exports = formatCompany = (model, service) ->
  unless hasData(model) # Setting missing props triggers re-render.
    getMissingData(service, model.get 'id').then (props) -> model.set props

  company = model.toJSON()
  
  _.escape "#{ company.name } (vat no. #{ company.vatNumber })"

