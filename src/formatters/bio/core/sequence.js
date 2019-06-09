// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
define('formatters/bio/core/sequence', function() {

  let SequenceFormatter;
  const lineLength = 40;

  return SequenceFormatter = function(seq) {
    let line;
    const id = seq.get('id');
    this.$el.addClass('dna-sequence');
    if (!seq.has('residues')) {
      if (model.__fetching == null) { model.__fetching = this.model.get('query').service.findById('Sequence', id); }
      model.__fetching.then(seq.set.bind(seq));
    }
    
    let residues = seq.get( 'residues' ) || '';
    const lines = [];

    while (residues.length > 0) {
      line = residues.slice(0, lineLength);
      const rest = residues.slice(lineLength);
      lines.push(line);
      residues = rest;
    }

    return ((() => {
      const result = [];
      for (line of Array.from(lines)) {         result.push(`<code>${ line }</code>`);
      }
      return result;
    })()).join("<br/>");
  };
});
