Backbone = require 'backbone'

{Service} = require 'imjs'
{connect} = Service

options = require '../options'
{History} = require '../models/history'
{Table} = require './results-table'
{Tools} = require './tools'
{Trail} = require './trail'
{ManagementTools} = require './management-tools'

class exports.DashBoard extends Backbone.View
    tagName: "div"
    className: "query-display row-fluid"

    asService = (service) ->
      if _(service).isString()
        connect root: service
      else if service.fetchModel?
        ## Is premade for us.
        service
      else
        connect service

    initialize: (service, @query, @queryEvents, @tableProperties) ->
      @columnHeaders = new Backbone.Collection
      @states = new History
      @events ?= {}
      @service = asService service

      @states.on 'reverted add', =>
        @loadQuery @states.currentQuery

    TABLE_CLASSES: "span9 im-query-results"

    loadQuery: (q) ->
      currentPageSize = @table?.getCurrentPageSize()
      @table?.remove()
      @main.empty()
      @table = new Table(q, @main, @columnHeaders)
      @table[k] = v for k, v of @tableProperties
      @table.pageSize = currentPageSize if currentPageSize?
      @table.render()
      q.on evt, cb for evt, cb of @queryEvents

    render: ->
      @$el.addClass options.StylePrefix
      @tools = $ """<div class="clearfix">"""
      @$el.append @tools
      @main = $ """<div class="#{ @TABLE_CLASSES }">"""
      @$el.append @main

      queryPromise = @service.query @query

      queryPromise.then (q) => @states.addStep 'Original state', q
      
      queryPromise.then (q) =>

        @renderQueryManagement(q)
        @renderTools(q)

      queryPromise.then null, (err) =>
        @$el.append """
          <div class="alert alert-error">
            <h1>Error</h1>
            <p>Unable to construct query: #{err.message or err}</p>
          </div>
        """

      this

    renderTools: (q) ->
        tools = @make "div", {class: "span3 im-query-toolbox"}
        @$el.append tools
        @toolbar = new Tools @states
        @toolbar.render().$el.appendTo tools

    renderQueryManagement: (q) ->
      managementGroup = new ManagementTools(@states, @columnHeaders)
      managementGroup.render().$el.appendTo @tools
      trail = new Trail(@states)
      trail.render().$el.appendTo managementGroup.el

