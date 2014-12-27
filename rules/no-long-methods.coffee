module.exports = class NoLongMethods

  rule:
    name: 'no_long_methods'
    message: 'Methods must not be longer than the given number of lines'
    level: 'error'
    value: 40
    description: 'Checks for method length'

  processFunction: (code, api, name) ->
    return unless code.body.expressions.length
    firstLine = code.locationData.first_line + 1
    lastLine = code.locationData.last_line - 1

    if lastLine - firstLine > @rule.value
      @errors.push api.createError
        context: code.variable
        message: "Functions must not be longer than #{ @rule.value } lines"
        lineNumber: firstLine
        lineNumberEnd: lastLine

    @lintNode code.body, api

  lintNode: (node, api, name = 'Anon function') ->
    node.traverseChildren false, (child) =>
      switch child.constructor.name
        when 'Code' then @processFunction child, api, name
        when 'Assign' then @lintNode child.value, api, child.variable
        when 'Block', 'Class' then @lintNode child, api
    return

  lintAST: (node, api) -> @lintNode node, api
