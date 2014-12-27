View = require '../../core-view'

# Just make sure that the bodies have access to the query.
module.exports = class ModalBody extends View

  initialize: ({@query}) -> super
