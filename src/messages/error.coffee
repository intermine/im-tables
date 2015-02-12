Messages = require '../messages'

Messages.setWithPrefix 'error',
  Oops: 'Oops!'
  EmailHelp: 'Email the help desk'
  ShowQuery: 'Show query'
  ConnectionError: 'Could not connect to server'

Messages.setWithPrefix 'error.client',
  Heading: 'Application error.'
  Body: """
    This is due to an unexpected error in the tables
    application - we are sorry for the inconvenience
  """

Messages.setWithPrefix 'error.server',
  Heading: "Server error"
  Body: """
    This is most likely related to the query that was just run. If you have
    time, please send us an email with details of this query to help us
    diagnose and fix this bug.
  """
