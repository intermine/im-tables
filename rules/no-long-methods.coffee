MAX_LEN = 5

module.exports = class NoLongMethods

  rule:
    name: 'no_long_methods'
    level: 'error'
    message: 'Methods msut not be longer than the given number of lines'
    description: 'Checks for method length'

  processFunction: (code, api) ->
    return unless code.body.expressions.length
    firstLine = code.locationData.first_line + 1
    lastLine = code.locationData.last_line + 1

    if lastLine - firstLine > MAX_LEN
      @errors.push api.createError
        context: code.variable
        lineNumber: firstLine
        lineNumberEnd: lastLine

    @lintNode code.body api

  lintNode: (node, api) -> node.traverseChildren false, (child) =>
    switch child.constructor.name
      when 'Code' then @processFunction child, api
      else @lintNode child, api

