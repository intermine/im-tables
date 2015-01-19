Messages = require '../messages'

Messages.setWithPrefix 'lists',
  DefaultName: '<%= typeName %> List (<%= new Date() %>)'
  Create: 'Create List'
  CreateListTitle: """
    Create a new List of <%= formatNumber(state.count) %>
    <%= pluralise(state.typeName, (state.count || 0)) %>
  """
  NoTags: 'No tags'
  AddTag: 'Add a new tag'
  AddTagBtn: 'add'
  RemoveTag: 'Remove this tag'

Messages.setWithPrefix 'lists.error',
  MustBeLoggedIn: 'You are not logged in. Anonymous users cannot create lists'
Messages.setWithPrefix 'lists.params',
  Name: 'List Name'
  NamePlaceholder: 'List name is required'
  Desc: 'List Description'
  DescPlaceholder: 'Enter a description'

Messages.setWithPrefix 'lists.params.help',
  Name: 'You must provide a unique list name'

