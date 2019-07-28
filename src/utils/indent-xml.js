// Rather naive (but generally effective) method of
// prettifying the otherwise compressed XML.
let indent;
module.exports = (indent = function(xml) {
  const lines = xml.split(/></);
  let indentLevel = 1;
  const buffer = [];
  for (let line of Array.from(lines)) {
    if (!/>$/.test(line)) {
      line = line + '>';
    }
    if (!/^</.test(line)) {
      line = `<${line}`;
    }

    const isClosing = /^<\/\w+\s*>/.test(line);
    const isOneLiner = /\/>$/.test(line) || (!isClosing && /<\/\w+>$/.test(line));
    const isOpening = !(isOneLiner || isClosing);

    if (isClosing) { indentLevel--; }

    buffer.push(new Array(indentLevel).join('  ') + line);
    
    if (isOpening) { indentLevel++; }
  }

  return buffer.join("\n");
});

