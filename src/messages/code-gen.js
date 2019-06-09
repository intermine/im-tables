/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Messages = require('../messages');

Messages.setWithPrefix('codegen', {
  AsHTML: "As HTML page",
  DialogueTitle: `\
Generated <%= Messages.getText("codegen.Lang", {lang: lang}) %>
Code for <%= query.name || "Query" %>\
`,
  CannotExportXML: `\
You cannot save the XML as a file directly. Please use your browser's cut
and paste functionality.\
`,
  PrimaryAction: 'Save',
  ChooseLang: 'Choose Language',
  ShowBoilerPlate: 'Show comments',
  HighlightSyntax: 'Highlight Syntax',
  GenerateCodeIn({lang}) { return `\
Generate ${ Messages.getText('codegen.Lang', {lang}) }
${ lang !== 'xml' ? 'code' : '' }\
`; },
  Lang({lang}) { switch (lang) {
    case 'py': return 'Python';
    case 'pl': return 'Perl';
    case 'java': return 'Java';
    case 'rb': return 'Ruby';
    case 'js': return 'JavaScript';
    case 'xml': return 'XML';
    default: throw new Error(`Unknown language ${ lang }`);
  } }
}
);

