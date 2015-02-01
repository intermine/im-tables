Messages = require '../messages'

Messages.setWithPrefix 'joins',
  Heading: 'Manage Relationships'
  Manage: -> Messages.getText 'joins.Heading' # synonymous by default - can be made distinct.
  ManageShort: 'Relationships'
  Inner: 'Required'
  Outer: 'Optional'
