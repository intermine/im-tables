# Rather naive (but generally effective) method of
# prettifying the otherwise compressed XML.
module.exports = indent = (xml) ->
  lines = xml.split /></
  indentLevel = 1
  buffer = []
  for line in lines
    unless />$/.test line
      line = line + '>'
    unless /^</.test line
      line = '<' + line

    isClosing = /^<\/\w+\s*>/.test(line)
    isOneLiner = /\/>$/.test(line) or (not isClosing and /<\/\w+>$/.test(line))
    isOpening = not (isOneLiner or isClosing)

    indentLevel-- if isClosing

    buffer.push new Array(indentLevel).join('  ') + line
    
    indentLevel++ if isOpening

  return buffer.join("\n")

