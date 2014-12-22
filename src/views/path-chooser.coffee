_ = require 'underscore'

Options = require '../options'
View = require '../core-view'

Attribute = require './pathtree/attribute'
RootClass = require './pathtree/root'
Reference = require './pathtree/reference'
ReverseReference = require './pathtree/reverse-reference'

appendField = (pth, fld) -> pth.append fld

module.exports = class PathChooser extends View

  tagName: 'ul'
      
  className: 'im-path-chooser'

  initialize: ({@query, @chosenPaths, @openNodes, @view, @trail}) ->
    super
    @path  = (_.last(@trail) or @model.get 'root')
    @cd    = @path.getEndClass()
    toPath = appendField.bind null, @path

    # These are all :: [PathInfo]
    for fieldType in ['attributes', 'references', 'collections']
      @[fieldType] = (toPath attr for name, attr of @cd[fieldType])

    @listenTo @model, 'change:allowRevRefs', @render
    @listenTo @openNodes, 'reset', @render

  getDepth: -> @trail.length

  showRoot: -> @getDepth() is 0 and @model.get('canSelectReferences')

  render: () ->
    super # does things like trigger shown, removes kids, etc.
    showId = Options.get 'ShowId'

    if @showRoot() # then show the root class
      root = @createRoot()
      @renderChild 'root', root

    for path in @attributes
      if showId or (path.end.name isnt 'id')
        attr = @createAttribute path
        @renderChild path.toString(), attr

    # Same logic for references and collections, but we want references to go first.
    for path in @references.concat(@collections)
      ref = @createReference path
      @renderChild path.toString(), ref

    this

  createRoot: ->
    new RootClass {@query, @model, @chosenPaths, @openNodes, @cd}

  createAttribute: (path) ->
    new Attribute {@model, @chosenPaths, @view, @query, @trail, path}

  createReference: (path) ->
    isLoop = @isLoop path
    allowingRevRefs = @model.get 'allowRevRefs'

    Ref = if isLoop and not allowingRevRefs then ReverseReference else Reference
    new Ref {@model, @chosenPaths, @query, @trail, path, @view, @openNodes, @createSubFinder}

  # Inject mechanism for creating a PathChooser to avoid a cyclic dependency.
  createSubFinder: (args) =>
    new PathChooser _.extend {@model, @query, @chosenPaths, @view, @openNodes}, args

  isLoop: (path) ->
    if path.end.reverseReference? and @path.isReference()
      if @path.getParent().isa path.end.referencedType
        if @path.end.name is path.end.reverseReference
          return true
    return false


