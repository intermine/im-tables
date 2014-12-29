_ = require 'underscore'

class Format

  constructor: (@id, @group, icon, needs = []) ->
    icon ?= @id
    desc = "export.format.description.#{ @id.toUpperCase() }"
    name = "export.format.name.#{ @id.toUpperCase() }"
    _.extend this, {icon, desc, name, needs}

  # Return true if this format has no requirements, or if at least
  # one of its required types are present.
  isSuitable: (availableTypes) ->
    return true if @needs.length is 0
    _.any @needs, (needed) -> availableTypes[needed]

# There are no good bio icons in the font-awesome
# set, but there are tickets to get them put in. Maybe
# one day soon these will work.
formats = [
  new Format('tsv', 'flat'),
  new Format('csv', 'flat'),
  new Format('xml', 'machine'),
  new Format('json', 'machine'),
  new Format('fasta', 'bio', 'dna', ['Protein', 'SequenceFeature']),
  new Format('gff3', 'bio', 'dna', ['SequenceFeature']),
  new Format('bed', 'bio', 'dna', ['SequenceFeature']),
  new Format('fake', 'fake', 'fake', ['Department'])
  new Format('fake_2', 'fake', 'fake', ['Company'])
]

exports.getFormats = (availableTypes) ->
  (f for f in formats when f.isSuitable availableTypes)

exports.registerFormat = ({id, icons, needs}) ->
  formats.push new Format id, icons, needs
