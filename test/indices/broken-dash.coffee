# There should be a helpful notice in the table, and the export button should
# be disabled.
$ = require 'jquery'
_ = require 'underscore'

# Code under test:
{configure, loadDash}  = require 'imtables/main'
{connection} = require '../lib/connect-to-service'

# Test helpers.
configure 'ModelDisplay.Initially.Closed', true
configure 'TableCell.PreviewTrigger', 'hover'
configure 'TableCell.IndicateOffHostLinks', false

NETWORK_ERROR = ['Network Error', 'Could not connect to endpoint', 'warning']

main = ->
  loadDash('#demo', {size: 15}, badQuery).then null, onErr
  loadDash('#demo', {}, badService).then null, onErr
  loadDash('#demo', {}, emptyView).then null, onErr

badQuery =
  service: connection
  query:
    name: 'I can haz rezults?'
    select: [
      'company.name',
      'name',
      'employees.name',
      'employees.age'
    ]
    from: 'Department'
    where: [[ 'name', 'iz', 'cats' ]]

emptyView =
  service: connection
  query:
    select: [
    ]
    from: 'Department'
    where: [['name', '=', 'Sales']]

badService =
  service:
    root: 'http://www.foo.bar/i/am/not/a/service'
  query:
    select: ['*']
    from: 'Employee'

onErr = (err) ->
  [title, body, level] = switch
    when /Network error/.test(err.message) then NETWORK_ERROR
    when /Illegal constraint/.test(err.message) then ['Bad Query', err.message]
    else ['Could not load table', err.message]

  alert = """
    <div class="alert alert-#{ level ? 'danger' }">
      <strong>#{ title }</strong>
      #{ _.escape body }
    </div>
  """
  $(document.body).append alert

$ main
