reqs = ['actions', 'actions/list-manager', 'actions/code-gen', 'actions/export-manager']

define 'actions/actionbar', using reqs..., (Actions, Lists, CodeGen, Exports) ->

  class ActionBar extends Actions
    extraClass: "im-action"
    actionClasses: -> [Lists, CodeGen, Exports]

  scope "intermine.query.actions", {ActionBar}

  ActionBar
