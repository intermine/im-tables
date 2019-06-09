// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
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
