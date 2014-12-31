_ = require 'underscore'

class Format

  constructor: ({@id, @group, icon, needs}) ->
    # Sigh, it's either this or list redundant info.
    ext = if @id is 'tab' then 'tsv' else @id
    EXT = ext.toUpperCase()
    icon ?= ext
    needs ?= []
    desc = "export.format.description.#{ EXT }"
    name = "export.format.name.#{ EXT }"
    _.extend this, {icon, desc, name, needs, ext, EXT}

  toString: -> @ext

  toJSON: -> {@id, @group, @icon, @needs, @ext}

  # Return true if this format has no requirements, or if at least
  # one of its required types are present.
  isSuitable: (availableTypes) ->
    return true if @needs.length is 0
    _.any @needs, (needed) -> availableTypes[needed]

# There are no good bio icons in the font-awesome
# set, but there are tickets to get them put in. Maybe
# one day soon these will work.
formats = [
  new Format(id: 'tab', group: 'flat'),
  new Format(id: 'csv', group: 'flat'),
  new Format(id: 'xml',  group: 'machine'),
  new Format(id: 'json', group: 'machine'),
  new Format(id: 'fasta', group: 'bio', icon: 'dna', needs: ['Protein', 'SequenceFeature']),
  new Format(id: 'gff3',  group: 'bio', icon: 'dna', needs: ['SequenceFeature']),
  new Format(id: 'bed',   group: 'bio', icon: 'dna', needs: ['SequenceFeature']),
  new Format(id: 'fake',   group: 'fake', icon: 'fake', needs: ['Department'])
  new Format(id: 'fake_2', group: 'fake', icon: 'fake', needs: ['Company'])
]

exports.getFormat = (id) -> _.findWhere formats, {id}

exports.getFormats = (availableTypes) ->
  (f for f in formats when f.isSuitable availableTypes)

exports.registerFormat = ({id, icons, needs}) ->
  formats.push new Format id, icons, needs
