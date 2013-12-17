Actions = require './actions'

Lists   = require './list-manager'
CodeGen = require './actions/code-gen'
Exports = require './actions/export'

module.exports = class ActionBar extends Actions
  extraClass: 'im-action'
  actionClasses: -> [Lists, CodeGen, Exports]

