Messages = require '../messages'

Messages.setWithPrefix 'lists',
  DefaultName: '<%= typeName %> List (<%= new Date() %>)'
  Create: 'Create List'
  CreateListTitle: """
    Create a new List
    <% if (state.count) { %>
      of <%= formatNumber(state.count) %>
      <%= pluralise(state.typeName, (state.count || 0)) %>
    <% } %>
  """
  NoTags: 'No tags'
  AddTag: 'Add a new tag'
  AddTagBtn: 'add'
  RemoveTag: 'Remove this tag'
  ShowExtraOptions: """<% if (minimised) { %>Show <% } %>Optional attributes"""
  NoObjectsSelected: """
    No objects selected. Choose objects from the table beneath. You can
    drag this dialog around if it is in the way.
  """

Messages.setWithPrefix 'lists.error',
  MustBeLoggedIn: 'You are not logged in. Anonymous users cannot create lists'

Messages.setWithPrefix 'lists.params',
  Name: 'List Name'
  NamePlaceholder: 'List name is required'
  Desc: 'List Description'
  DescPlaceholder: 'Enter a description'

Messages.setWithPrefix 'lists.params.help',
  Name: 'You must provide a unique list name'

Messages.setWithPrefix 'lists.picker',
  Expand: 'show more options'
  Collapse: 'show fewer options'
