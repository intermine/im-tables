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
    'Location.start': false,
    'Location.end': false,
    'Organism.name': false,
    'Publication.title': false,
    'Sequence.residues': false

