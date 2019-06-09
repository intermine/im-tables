/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
define('perma-query', function() {

  let getPermaQuery;
  const {get}  = intermine.funcutils;
  const {any, zip} = _;
  const {Deferred} = jQuery;
  const defer = x => Deferred(function() { return this.resolve(x); });
  const whenAll = promises => $.when.apply($, promises).then((...results) => results.slice());

  const replaceIdConstraint = (classkeys, query) => function(c) {
    let path = query.makePath(c.path);
    const def = new Deferred;
    if (!( ['=', '=='].includes(c.op) && (path.end.name === 'id') )) {
      def.resolve(c);
    } else {
      const type = path.getParent().getType().name;
      const keys = classkeys[type];
      if ((keys == null)) {
        def.reject(`No class keys configured for ${ type }`);
      } else {
        const finding = query.service.rows({select: keys, where: {id: c.value}}).then(get(0));
        finding.fail(def.reject);
        finding.then(function(values) {
          let value;
          if (!values) { return def.reject(`${ type }@${ c.value } not found`); }
          for ([path, value] of Array.from(zip(keys, values))) {
            if (value != null) {
              return def.resolve({path, value, op: '=='});
            }
          } // Must be ==, because symbols.
          return def.reject(`${ type }@${ c.value } has no identifying fields`);
        });
      }
    }

    return def.promise();
  } ;

  return getPermaQuery = function(query) {
    let c;
    const nodes = ((() => {
      const result = [];
      for (c of Array.from(query.constraints)) {         if ((c.type == null)) {
          result.push(query.makePath(c.path));
        }
      }
      return result;
    })());
    const containsIdConstraint = nodes.length && any(nodes, n => 'id' === (n.end != null ? n.end.name : undefined));
    const copy = query.clone();
    if (!containsIdConstraint) { return defer(copy); }
    const def = new Deferred;
    const applyNewCons = function(newCons) {
      copy.constraints = newCons;
      return def.resolve(copy);
    };
    query.service.get('classkeys').then(function({classes}) {
      const replaceIdCon = replaceIdConstraint(classes, copy);
      return whenAll((() => {
        const result1 = [];
        for (c of Array.from(copy.constraints)) {           result1.push(replaceIdCon(c));
        }
        return result1;
      })()).then(applyNewCons).fail(def.reject);
    });
    return def.promise();
  };
});

