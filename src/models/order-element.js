PathModel = require './path'

module.exports = class OrderElementModel extends PathModel

  constructor: ({path, direction}) ->
    super path
    direction ?= 'ASC'
    @set {direction}

  asOrderElement: -> @pick 'path', 'direction'

  toOrderString: -> "#{ @get 'path'} #{ @get 'direction' }"
