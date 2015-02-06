# Wrapper that caches the results of findById and count
# it fulfils the contract of ServiceType from item-preview
# This is not for general use, as it *only* returns promises, 
# and ignores all callbacks.
#
# When Proxies come into general use, this would be an excellent
# use case for them.
class PreviewCachingService

  constructor: (@wrapped) ->
    @root = @wrapped.root
    @_foundById = {}
    @_counts = {}

  fetchModel: -> @wrapped.fetchModel()

  findById: (type, id) ->
    @_foundById["#{ type }:#{ id }"] ?= @wrapped.findById(type, id)

  count: (query) ->
    @_counts[JSON.stringify query] ?= @wrapped.count(query)

  destroy: ->
    @_foundById = {}
    @_counts = {}
    delete @wrapped

# Factory that wraps the service in a thick layer of sweet
# caching logic.
#
# The purpose of this is to minimise the performance penalty
# of having multiple cells representing the same entity on
# the same table - this way they share data requested through
# the service.
module.exports = class PopoverFactory

  constructor: (service, @Preview) ->
    @service = new PreviewCachingService service

  # IMObject -> jQuery
  get: (obj) ->
    {Preview, service} = @
    type = obj.get 'class' # best to avoid using 'class' as a key.
    id = obj.get 'id'
    model = {type, id}

    new Preview {service, model}
  
  # Remove all popovers.
  destroy: ->
    @service.destroy()
    delete @service

