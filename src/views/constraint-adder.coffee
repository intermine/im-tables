$ = require 'jquery'
Backbone = require 'backbone'
{Query} = require 'imjs'
{NewConstraint} = require './new-constraint'
{PathChooser} = require './path-chooser'
{getMessage, defaultMessages} = require '../messages'

defaultMessages
  'constraints.browse-for-column': 'Browse for column'

class exports.ConstraintAdder extends Backbone.View

    tagName: "form"
    className: "form im-constraint-adder row-fluid im-constraint"

    initialize: (@query) ->

    events: ->
        'submit': 'handleSubmission'
        'click .im-collapser': 'collapseBranches'
        'change .im-allow-rev-ref': 'allowReverseRefs'

    collapseBranches: ->
      @$pathfinder?.trigger 'collapse:tree-branches'

    allowReverseRefs: ->
      @$pathfinder?.allowRevRefs @$('.im-allow-rev-ref').is(':checked')

    handleClick: (e) ->
        e.preventDefault()
        unless $(e.target).is 'button'
            e.stopPropagation()
        if $(e.target).is 'button.btn-primary'
            @handleSubmission(e)

    handleSubmission: (e) =>
        e.preventDefault()
        e.stopPropagation()
        if @chosen?
            con = path: @chosen.toString()

            @newCon = new NewConstraint(@query, con)
            @newCon.render().$el.insertAfter @el
            @$('.btn-primary').fadeOut('fast') # Only add one constraint at a time...
            @$pathfinder?.remove()
            @$pathfinder = null
            @query.trigger 'editing-constraint'
        else
            console.log "Nothing chosen"

    handleChoice: (path, isNewChoice) =>
        if isNewChoice
            @chosen = path
            @$('.btn-primary').fadeIn('slow')
        else
            @chosen = null
            @$('.btn-primary').fadeOut('slow')

    isDisabled: (path) -> false

    getTreeRoot: () -> @query.getPathInfo(@query.root)

    refsOK: true
    multiSelect: false

    reset: () ->
        @trigger 'resetting:tree'
        @$pathfinder?.remove()
        @$pathfinder = null
        @$('.im-tree-option').addClass 'hidden'

    showTree: (e) =>
      @$('.im-tree-option').removeClass 'hidden'
      @trigger 'showing:tree'
      if @$pathfinder?
        @reset()
      else
        treeRoot = @getTreeRoot()
        pathFinder = new PathChooser(@query, treeRoot, 0, @handleChoice, @isDisabled, @refsOK, @multiSelect)
        pathFinder.render()
        @$el.append(pathFinder.el)
        pathFinder.$el.show().css top: @$el.height()
        @$pathfinder = pathFinder

    VALUE_OPS =  Query.ATTRIBUTE_VALUE_OPS.concat(Query.REFERENCE_OPS)

    isValid: () ->
        if @newCon?
          if not @newCon.con.has('op')
              return false
          if @newCon.con.get('op') in VALUE_OPS
              return @newCon.con.has('value')
          if @newCon.con.get('op') in Query.MULTIVALUE_OPS
              return @newCon.con.has('values')
          return true
        else
          return false

    render: ->
        browser = $ """
          <button type="button" class="btn btn-chooser" data-toggle="button">
            <i class="icon-sitemap"></i>
            <span>#{ getMessage 'constraints.browse-for-column' }</span>
          </button>
        """

        approver = $ @make 'button', {type: "button", class: "btn btn-primary"}, "Choose"
        @$el.append browser
        @$el.append approver
        approver.click @handleSubmission
        browser.click @showTree
        @$('.btn-chooser').after """
          <label class="im-tree-option hidden">
            #{ getMessage 'columns.AllowRevRef' }
            <input type="checkbox" class="im-allow-rev-ref">
          </label>
          <button class="btn im-collapser im-tree-option hidden" type="button" >
            #{ getMessage 'columns.CollapseAll' }
          </button>
        """
        this

