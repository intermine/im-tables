// Compact multiple empty lines and trim
let stripExtraneousWhiteSpace;
module.exports = (stripExtraneousWhiteSpace = function(str) {
  if (str == null) { return; }
  str = str.replace(/\n\s*\n/g, '\n\n');
  return str.replace(/(^\s*|\s*$)/g, '');
});

