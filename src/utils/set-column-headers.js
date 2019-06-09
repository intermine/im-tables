/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
exports.setHeaders = function(query) { return query.service.get("/classkeys").then(({classes}) => {
    // need at least one example row - any will do.
    // if there isn't one, then return and wait to be called later.
    let r;
    let path, replaces, col;
    if (!__guard__(this.model.get('cache'), x => x.length)) { return; }
    const [row] = Array.from(this.model.get('cache'));
    const classKeys = classes;
    const replacedBy = {};
    const {longestCommonPrefix, getReplacedTest} = intermine.utils;

    // Create the columns
    const cols = (() => {
      const result = [];
      for (var cell of Array.from(row)) {
        path = q.getPathInfo(cell.column);
        replaces = (() => {
          if (cell.view != null) { // subtable of this cell.
          const commonPrefix = longestCommonPrefix(cell.view);
          path = q.getPathInfo(commonPrefix);
          return replaces = (Array.from(cell.view).map((v) => q.getPathInfo(v)));
        } else {
          return [];
        }
        })();
        result.push({path, replaces});
      }
      return result;
    })();

    // Build the replacement information.
    for (col of Array.from(cols)) {
      if (col.path.isAttribute() && intermine.results.shouldFormat(col.path)) {
        const p = col.path;
        const formatter = intermine.results.getFormatter(p);
      
        // Check to see if we should apply this formatter.
        if (this.canUseFormatter(formatter)) {
          col.isFormatted = true;
          col.formatter = formatter;
          for (r of Array.from((formatter.replaces != null ? formatter.replaces : []))) {
            const subPath = `${ p.getParent() }.${ r }`;
            if (replacedBy[subPath] == null) { replacedBy[subPath] = col; }
            if (Array.from(q.views).includes(subPath)) { col.replaces.push(q.getPathInfo(subPath)); }
          }
        }
      }
    }

    const isKeyField = function(col) {
      if (!col.path.isAttribute()) { return false; }
      const pType = col.path.getParent().getType().name;
      const fName = col.path.end.name;
      return Array.from((classKeys != null ? classKeys[pType] : undefined) != null ? (classKeys != null ? classKeys[pType] : undefined) : []).includes(`${pType}.${fName}`);
    };

    const explicitReplacements = {};
    for (col of Array.from(cols)) {
      for (r of Array.from(col.replaces)) {
        explicitReplacements[r] = col;
      }
    }

    const isReplaced = getReplacedTest(replacedBy, explicitReplacements);

    const newHeaders = (() => {
      const result1 = [];
      for (col of Array.from(cols)) {
        if (!isReplaced(col)) {
          if (col.isFormatted) {
            if (!Array.from(col.replaces).includes(col.path)) { col.replaces.push(col.path); }
            if (isKeyField(col) || (col.replaces.length > 1)) { col.path = col.path.getParent(); }
          }
          result1.push(col);
        }
      }
      return result1;
    })();

    return this.columnHeaders.reset(newHeaders);
}); };



function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}