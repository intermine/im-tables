const bio_formatters = ['chromosome-location', 'sequence', 'organism', 'publication'].map((x) =>
  `formatters/bio/core/${ x }`);

define('formatters/bio/core', using(...Array.from(bio_formatters), function(Chr, Seq, Org, Pub) {

  // Export out to formatter name-space
  scope('intermine.results.formatters', {

    Location: Chr,
    Sequence: Seq,
    Publication: Pub,
    Organism: Org
  }
  );

  return scope('intermine.results.formatsets.genomic', {
    'Location.start': false,
    'Location.end': false,
    'Organism.name': false,
    'Publication.title': false,
    'Sequence.residues': false
  }
  );
})
);

