View = require '../core-view'

# Base class for various labels.
module.exports = class LabelView extends View

  RERENDER_EVENT: 'change'

  tagName: 'span'

