define 'actions/actionbar', using 'actions', 'actions/list-manager', 'actions/code-gen', (Actions, ListManager, CodeGenerator) ->

  class ActionBar extends Actions
    extraClass: "im-action"
    actionClasses: ->
      [ListManager, CodeGenerator, intermine.query.export.ExportDialogue]

  scope "intermine.query.actions", {ActionBar}

  ActionBar
