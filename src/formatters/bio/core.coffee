bio_formatters = for x in ['chromosome-location', 'sequence', 'organism', 'publication']
  "formatters/bio/core/#{ x }"

define 'formatters/bio/core', using bio_formatters..., (Chr, Seq, Org, Pub) ->

  # Export out to formatter name-space
  scope 'intermine.results.formatters',

    Location: Chr
    Sequence: Seq
    Publication: Pub
    Organism: Org

  scope 'intermine.results.formatsets.genomic',
    'Location.start': true,
    'Location.end': true,
    'Organism.name': true,
    'Publication.title': false,
    'Sequence.residues': true

