_  = require 'underscore'

Modal = require '../modal'

{large_table_disuader} = require '../../templates'

# Definitions of the actions this modal returns
Actions =
  ACCEPT: 'accept' # The user accepted the size, despite the warning
  CONSTRAIN: 'constrain' # The user wants to add a filter.
  BACK: 'back' # The user wants to go back a page.
  FWD: 'forward' # The user wants to go forward a page.
  EXPORT: 'export' # The user wants to download data.
  DISMISS: 'dismiss' # The user does not want to change the page size.

# modal dialogue that presents user with range of other options instead of
# large tables, and lets them choose one.
module.exports = class LargeTableDisuader extends Modal

  className: -> 'im-page-size-sanity-check fade ' + super

  template: _.template large_table_disuader

  act: -> 
    @resolve "accept"

  events: -> _.extend super,
    'click .btn-primary':         (=> @resolve Actions.ACCEPT)
    'click .add-filter-dialogue': (=> @resolve Actions.CONSTRAIN)
    'click .page-backwards':      (=> @resolve Actions.BACK)
    'click .page-forwards':       (=> @resolve Actions.FWD)
    'click .download-menu':       (=> @resolve Actions.EXPORT)
