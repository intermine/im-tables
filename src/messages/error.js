const Messages = require('../messages');

Messages.setWithPrefix('error', {
  Oops: 'Oops! - Sorry we cannot get that table for you.',
  EmailHelp: 'Send a bug report',
  ShowQuery: 'Show query',
  ShowError: 'Show error',
  ConnectionError: 'Could not connect to server'
}
);

Messages.setWithPrefix('error.mail',
  {Subject: '[IMTABLES] - Error running query.'});

Messages.setWithPrefix('error.client', {
  Heading: 'Application error.',
  Body: `\
This is due to an unexpected error in the tables
application - this is our fault, and we are sorry for the
inconvenience. Please send us the pre-filled bug report so
we can fix this as soon as possible.\
`
}
);

Messages.setWithPrefix('error.server', {
  Heading: "Server error - our bad!",
  Body: `\
This is most likely related to the query that was just run. If you have
two minutes, please send us an email with details of this query to help us
diagnose and fix this bug - we have already pre-filled the bug report,
you just need to hit send (and maybe give us some extra details).
Alternatively, you might be able to fix this query by changing its column, 
filters or joins; use the tools above to do so.\
`
}
);
