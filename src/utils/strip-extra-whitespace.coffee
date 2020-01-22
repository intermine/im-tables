# Compact multiple empty lines and trim
module.exports = stripExtraneousWhiteSpace = (str) ->
  return unless str?
  str = str.replace /\n\s*\n/g, '\n\n'
  str.replace /(^\s*|\s*$)/g, ''

