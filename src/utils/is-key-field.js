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

