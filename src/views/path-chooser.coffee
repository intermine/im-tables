_ = require 'underscore'

Options = require '../options'
View = require '../core-view'
Attribute = require './pathtree/attribute'
RootClass = require './pathtree/root'
Reference = require './reference'
ReverseReference = require './reverse-reference'

appendField = (pth, fld) -> pth.append fld

module.exports = class PathChooser extends View

    tagName: 'ul'
        
    initialize: ({@query, @chosenPaths, @openNodes, @trail}) ->
      super
      @path  = trail.reduce appendField, @model.get 'root'
      @cd    = path.getEndClass()
      toPath = appendField.bind null, @path

      # These are all :: [PathInfo]
      for fieldType in ['attributes', 'references', 'collections']
        @[fieldType] = (toPath attr for name, attr of @cd[fieldType])

      @listenTo @model, 'change:allowRevRefs', @render
      @listenTo @openNodes, 'reset', @render

    getDepth: -> @trail.length

    showRoot: -> @getDepth() is 0 and @model.get('canSelectReferences')

    render: () ->
      super # does things like trigger shown,...
      showId = Options.get 'ShowId'

      if @showRoot() # then show the root class
        root = @createRoot()
        @renderChild 'root', root

      for apath in @attributes
        if showId or apath.end.name isnt 'id'
          attr = @createAttribute apath
          @renderChild attr.toString(), attr

      # Same logic for references and collections, but we want references to go first.
      for rpath in @references.concat(@collections)
        ref = @createReference rpath
        @renderChild rpath.toString(), ref

      this

  createRoot: ->
    new RootClass {@query, @model, @chosenPaths, @cd}

  createAttribute: (path) ->
    new Attribute {@model, @chosenPaths, @query, @trail, path}

  createReference: (path) ->
    isLoop = @isLoop path
    allowingRevRefs = @model.get 'allowRevRefs'

    Class = if isLoop and not allowingRevRefs then ReverseReference else Reference
    new Class {@model, @chosenPaths, @query, @trail, path, @openNodes, @createSubFinder}

  # Inject mechanism for creating a PathChooser to avoid a cyclic dependency.
  createSubFinder: (args) =>
    new PathChooser args

  isLoop: (path) ->
    if path.end.reverseReference? and @path.isReference()
      if @path.getParent().isa path.end.referencedType
        if @path.end.name is path.end.reverseReference
          return true
    return false


