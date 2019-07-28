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
