Messages = require '../messages'

Messages.setWithPrefix 'lists',
  DefaultName: '<%= typeName %> List (<%= new Date() %>)'
  Create: 'Create List'
  Append: 'Add to List'
  CreateListOrAppendToList: 'Save as List'
  CreateListTitle: """
    Create a new List
    <% if (state.count) { %>
      of <%= formatNumber(state.count) %>
      <%= pluralise(state.typeName, (state.count || 0)) %>
    <% } %>
  """
  AppendToListTitle: """
    Add
    <% if (state.count) { %>
      <%= formatNumber(state.count) %>
      <%= pluralise(state.typeName, (state.count || 0)) %>
    <% } %>
    to
    <%= target || 'a List' %>
  """
  NoTags: 'No tags'
  AddTag: 'Add a new tag'
  AddTagBtn: 'add'
  RemoveTag: 'Remove this tag'
  ShowExtraOptions: """<% if (minimised) { %>Show <% } %>Optional attributes"""
  TargetDoesNotExist: """Your target list does not exist."""
  NoTargetSelected: 'Please select a target list.'
  PossibleAppendTarget: """
    <%= name %> (<%= formatNumber(size) %> <%= pluralise((typeName || 'item'), size) %>)
  """
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
  Target: 'Choose list to append items to'

Messages.setWithPrefix 'lists.params.help',
  Name: 'You must provide a unique list name'
  Target: 'You must select a target list'

Messages.setWithPrefix 'lists.picker',
  Expand: 'show more options'
  Collapse: 'show fewer options'

Messages.setWithPrefix 'lists.append',
  NoSuitableLists: """
    No suitable lists were found
    <% if (model.type) { %>
      for <%- model.type %>.
    <% } else { %>
      because no items are selected, or they have no common type.
    <% } %>
  """
