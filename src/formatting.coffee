# A set of functions of the signature:
#   (Backbone.Model, intermine.Query, jQuery) -> {value: string, field: string}
#
# Defining a formatter means that this function will be used to display data
# rather than the standard id being shown.

# TODO: move these into own class files

ChrLocFormatter = (model) ->
  id = model.get 'id'
  @$el.addClass 'chromosome-location'
  needs = ['start', 'end', 'chr']
  unless model._fetching? or _.all(needs, (n) -> model.has n)
    console.log "Fetching extra data for Location #{ id }"
    model._fetching = @options.query.service.findById 'Location', id
    model._fetching.done (loc) ->
      model.set start: loc.start, end: loc.end, chr: loc.locatedOn.primaryIdentifier
  
  {start, end, chr} = model.toJSON()
  "#{chr}:#{start}-#{end}"

ChrLocFormatter.replaces = [
  'locatedOn.primaryIdentifier', 'start', 'end', 'strand'
]

ChrLocFormatter.merge = (location, chromosome) ->
  if chromosome.has 'primaryIdentifier'
    location.set chr: chromosome.get('primaryIdentifier')

SequenceFormatter = (model) ->
  id = model.get 'id'
  @$el.addClass 'dna-sequence'
  unless model.has('residues')
    model._formatter_promise ?= @options.query.service.findById 'Sequence', id
    model._formatter_promise.done (seq) -> model.set seq
  
  sequence = model.get( 'residues' ) || ''
  lines = []

  while sequence.length > 0
    line = sequence.slice 0, 80
    rest = sequence.slice 80
    lines.push line
    sequence = rest

  lines.join("\n")

PublicationFormatter = (model) ->
  id = model.get 'id'
  @$el.addClass 'publication'
  unless model.has('title') and model.has('firstAuthor') and model.has('year')
    model._formatter_promise ?= @options.query.service.findById 'Publication', id
    model._formatter_promise.done (pub) -> model.set pub

  {title, firstAuthor, year} = model.toJSON()
  "#{title} (#{firstAuthor}, #{year})"

PublicationFormatter.replaces = [ 'title', 'firstAuthor', 'year' ]

scope "intermine.results.formatters", {
    Manager: (model) ->
      id = model.get 'id'
      unless (model.has('title') and model.has('name'))
        model._formatter_promise ?= @options.query.service.findById 'Manager', id
        model._formatter_promise.done (manager) -> model.set manager
      
      data = _.defaults model.toJSON(), {title: '', name: ''}

      _.template "<%- title %> <%- name %>", data

    Sequence: SequenceFormatter
    Location: ChrLocFormatter
    Publication: PublicationFormatter

    Organism: (model, query, $cell) ->
      id = model.get 'id'
      @$el.addClass 'organism'
      templ = _.template """
        <span class="name"><%- shortName %></span>
      """
      unless (model.has('shortName') and model.has('taxonId'))
        model._formatter_promise ?= @options.query.service.findById 'Organism', id
        model._formatter_promise.done (org) ->
          model.set org

      data = _.extend {shortName: ''}, model.toJSON()
      templ data

}

scope "intermine.results.formatsets", {
  testmodel: { 'Manager.name': true },
  genomic: {
    'Location.*': true,
    'Organism.name': true,
    'Publication.title': true,
    'Sequence.residues': true
  }
}

scope "intermine.results", {
    getFormatter: (model, type) ->
        formatter = null
        unless type?
          [model, type] = [model.model, model.getParent()?.getType()]
        type = type.name or type
        types = [type].concat model.getAncestorsOf(type)
        formatter or= intermine.results.formatters[t] for t in types
        return formatter

    shouldFormat: (path, formatSet) ->
      return false unless path.isAttribute()
      model = path.model
      formatSet ?= model.name
      cd = if path.isAttribute() then path.getParent().getType() else path.getType()
      fieldName = path.end.name
      formatterAvailable = intermine.results.getFormatter(path.model, cd)?

      return false unless formatterAvailable
      return true if fieldName is 'id'
      ancestors = [cd.name].concat path.model.getAncestorsOf cd.name
      formats = intermine.results.formatsets[formatSet] ? {}
      
      for a in ancestors
        return true if (formats["#{a}.*"] or formats["#{ a }.#{fieldName}"])
      return false

}

