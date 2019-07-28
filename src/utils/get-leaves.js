let getLeaves;
module.exports = (getLeaves = function(o, exceptList) {
  let v;
  const values = ((() => {
    const result = [];
    for (let name in o) {
      const leaf = o[name];
      if ((leaf != null) && !Array.from(exceptList).includes(name)) {
        result.push(leaf);
      }
    }
    return result;
  })());
  const attrs = ((() => {
    const result1 = [];
    for (v of Array.from(values)) {       if ((v.objectId == null)) {
        result1.push(v);
      }
    }
    return result1;
  })());
  const refs = ((() => {
    const result2 = [];
    for (v of Array.from(values)) {       if (v.objectId != null) {
        result2.push(v);
      }
    }
    return result2;
  })());
  return refs.reduce(((ls, ref) => ls.concat(getLeaves(ref, exceptList))), attrs);
});
