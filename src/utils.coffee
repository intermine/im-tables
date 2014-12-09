do ($ = jQuery) ->

    # Simple tree-walker
    walk = (obj, f) ->
      for own k, v of obj
        if _.isObject v
          walk v, f
        else
          f obj, k, v

    # Thorough deep cloner.
    copy = (obj) ->
      return obj unless _.isObject obj
      dup = if _.isArray(obj) then [] else {}
      for own k, v of obj
        if _.isArray v
          duped = []
          duped.push copy x for x in v
          dup[k] = duped
        else if not _.isObject v
          dup[k] = v
        else
          dup[k] = copy v
      dup

    getContainer = (el) -> el.closest '.' + intermine.options.StylePrefix

    addStylePrefix = (x) -> (elem) -> $(elem).addClass(intermine.options.StylePrefix); x

    ##
    # Very naïve English word pluralisation algorithm
    #
    # @param {String} word The word to pluralise.
    # @param {Number} count The number of items this word represents.
    ##
    pluralise = (word, count) ->
        if count is 1
            word
        else if word.match /(s|x|ch)$/
            word + "es"
        else if word.match /[^aeiou]y$/
            word.replace /y$/, "ies"
        else
            word + "s"

    # TODO: unit tests
    numToString = (num, sep, every) ->
        rets = []
        i = 0
        chars =  (num + "").split("")
        len = chars.length
        groups = _(chars).groupBy (c, i) -> Math.floor((len - (i + 1)) / every).toFixed()
        while groups[i]
            rets.unshift groups[i].join("")
            i++
        return rets.join(sep)


    getParameter = (params, name) ->
        _(params).chain().select((p) -> p.name == name).pluck('value').first().value()

    modelIsBio = (model) -> !!model?.classes['Gene']

    requiresAuthentication = (q) -> _.any q.constraints, (c) -> c.op in ['NOT IN', 'IN']

    organisable = (path) ->
      path.getEndClass().name is 'Organism' or path.getType().fields['organism']?

    uniquelyFlat = _.compose _.uniq, _.flatten

    longestCommonPrefix = (paths) ->
      parts = paths[0].split /\./
      prefix = parts.shift() # Root, must be common prefix.
      prefixesAll = (pf) -> _.all paths, (path) -> 0 is path.indexOf pf
      for part in parts when prefixesAll nextPrefix = "#{prefix}.#{part}"
        prefix = nextPrefix
      prefix

    getReplacedTest = (replacedBy, explicitReplacements) -> (col) ->
      p = col.path
      return false unless intermine.results.shouldFormat(p) or explicitReplacements[p]
      replacer = replacedBy[p]
      replacer ?= replacedBy[p.getParent()] if p.isAttribute() and p.end.name is 'id'
      replacer and replacer.formatter? and col isnt replacer
    
    getOrganisms = (q, cb) -> $.when(q).then (query) ->
      def = $.Deferred()
      def.done cb if cb?
      done = _.compose def.resolve, uniquelyFlat

      mustBe = ((c.value or c.values) for c in query.constraints when (
        (c.op in ['=', 'ONE OF', 'LOOKUP']) and c.path.match(/(o|O)rganism(\.\w+)?$/)))

      if mustBe.length
        done mustBe
      else
        toRun = query.clone()
        newView = for n in toRun.getViewNodes() when organisable n
          opath = if n.getEndClass().name is 'Organism' then n else n.append('organism')
          opath.append 'shortName'

        if newView.length
          toRun.select(_.uniq newView, String)
                .orderBy([])
                .rows()
                .then(done, -> done [])
        else
          done []

      return def.promise()

    openWindowWithPost = (uri, name, params) ->

      form = $ """
          <form style="display;none" method="POST" action="#{ uri }" 
               target="#{ name }#{ new Date().getTime() }">
      """

      addInput = (k, v) ->
        input = $("""<input name="#{ k }" type="hidden">""")
        form.append(input)
        input.val(v)

      for k, v of params then do (k, v) ->
        if _.isArray v
          addInput k, v_ for v_ in v
        else
          addInput k, v

      form.appendTo 'body'
      w = window.open("someNonExistantPathToSomeWhere", name)
      form.submit()
      form.remove()
      w.close()

    ERROR = _.template """
      <div class="alert alert-error">
        <p class="apology">Could not fetch summary</p>
        <pre><%- message %></pre>
      </div>
    """

    renderError = (dest) -> (response, err) ->
      $el = $(dest).empty()
      message = try
        JSON.parse(response.responseText).error
      catch e
        response?.responseText ? err
      $el.append ERROR {message}

    class ItemView extends Backbone.View

      initialize: ->
        unless @model?
          @model = new Backbone.Model
        unless @model.toJSON?
          @model = new Backbone.Model @model

      renderError: (resp) -> renderError(@el) resp

      getData: -> @model.toJSON()

      render: ->

        if @template?
          @$el.html @template @getData()
        
        @trigger 'rendered'

        this

    class ClosableCollection extends Backbone.Collection

      close: ->
        @each (m) ->
          m.destroy()
          m.off()
        @reset()
        this

    Tab = jQuery.fn.tab.noConflict()

    scope 'intermine.bootstrap', {Tab}

    scope 'intermine.views', {ItemView}

    scope 'intermine.models', {ClosableCollection}

    scope "intermine.utils", {
      copy, walk, getOrganisms, requiresAuthentication, modelIsBio, renderError,
      getParameter, numToString, pluralise, addStylePrefix, getContainer,
      openWindowWithPost, longestCommonPrefix, getReplacedTest
    }
            
