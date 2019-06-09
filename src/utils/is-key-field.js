/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Determine whether a path represents a key field, based on the
// class key definitions.
// :: {string: [string]} -> PathInfo -> bool
let isKeyField;
module.exports = (isKeyField = classKeys => function(path) {
  if (!path.isAttribute()) { return false; }
  const type      = path.getParent().getType().name;
  const fieldName = path.end.name;
  const keys      = (classKeys != null ? classKeys[type] : undefined) != null ? (classKeys != null ? classKeys[type] : undefined) : [];
  return (Array.from(keys).includes(`${type}.${fieldName}`));
} );

