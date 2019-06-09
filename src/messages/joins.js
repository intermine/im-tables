const Messages = require('../messages');

Messages.setWithPrefix('joins', {
  Heading: 'Manage Relationships',
  Manage() { return Messages.getText('joins.Heading'); }, // synonymous by default - can be made distinct.
  ManageShort: 'Relationships',
  Inner: 'Required',
  Outer: 'Optional',
  ExplanationTitle: 'What does this do?',
  Explanation: `\
You can specify the entity relationships within the query here. This
has a couple of effects - one is to exclude a class of matched results, the
other is to change the way the results are presented in the table.
If set to required, then an entity which matches the filters
but lacks the given relationship will not be returned in the results,
whereas if set to optional it will. This also has an effect on the
way that results are laid out: required collection relationships
are returned inline, whereas optional collection relationships are
returned as nested sub-tables within the main result set.\
`
}
);
