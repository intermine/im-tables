Messages = require '../messages'

Messages.setWithPrefix 'constraints',
  Heading: '<%= n %> Active <%= pluralise("Filter", n) %>'
  AddNewFilter: 'Add New Filter'
  AddFilter: 'Add filter'
  AddNew: "Add Filter"
  DefineNew: 'Define a new filter'
  EditOrRemove: 'edit or remove the currently active filters'
  None: 'No active filters'
  NoOfValues: '<%= (n === 1) ? "one" : formatNumber(n) %> <%= pluralise("value", n) %>'
  NoOfIds: '<%= (n === 1) ? "one" : formatNumber(n) %> <%= pluralise("ID", n) %>'
  ISA: 'is a'
  LookupIn: 'in'
  AddConFor: 'Add filter to <%= typeName %> <%= _.last(parts) %>'
