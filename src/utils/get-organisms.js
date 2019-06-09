// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let getOrganisms;
const _ = require('underscore');
const {Promise} = require('es6-promise');

const uniquelyFlat = _.compose(_.uniq, _.flatten);

// A path has an organism if it can have the 'organism' segment appended, e.g. 'Gene'
const hasAnOrganism = path => __guard__(path.getType().fields, x => x.organism) != null;

// A path is organisable if it refers to an Organism, or something that has an .organism
const organisable = path => (path.getEndClass().name === 'Organism') || (hasAnOrganism(path));

// Test if path refers to one of the paths we want.
const nameOrShortName = path => (path.getEndClass().name === 'Organism') && (['name', 'shortName'].includes(path.end.name));

// Value is wild if it includes a wildcard ('*')
const wild = value => (value != null) && /\*/.test(value);

// The equality operators
const EQL = ['=', '==', 'ONE OF'];

// Determine the organisms a query refers to
// :: (Query) -> Promise<Array<Organism.shortName>>
// Assumes that Organism.shortName (string) exists in the model.
module.exports = (getOrganisms = query => new Promise(function(resolve, reject) {
  let c;
  const done = _.compose(resolve, uniquelyFlat); // Flatten and remove duplicates before resolution.
  const nothing = () => resolve([]);                // resolve with the empty list on error/failure.

  // either paths constrained directly (eg. Organism.name = Drosophila melanogaster)
  const directly = ((() => {
    const result = [];
    for (c of Array.from(query.constraints)) {       if ((Array.from(EQL).includes(c.op)) && (!wild(c.value)) && (nameOrShortName(query.makePath(c.path)))) {
        result.push((c.value || c.values));
      }
    }
    return result;
  })());
  // Or the extra value of lookup constraints on paths that have an
  // organism (e.g. Gene LOOKUP 'foo')
  const onLookups = ((() => {
    const result1 = [];
    for (c of Array.from(query.constraints)) {       if ((c.op === 'LOOKUP') && (c.extraValue != null) && (hasAnOrganism(query.makePath(c.path)))) {
        result1.push(c.extraValue);
      }
    }
    return result1;
  })());
  // If we are constrained to one or more organisms, then we assume it must be one of those.
  const mustBe = _.union(directly, onLookups);

  if (mustBe.length) {
    return done(mustBe);
  } else {
    const newView = (() => {
      const result2 = [];
      for (let n of Array.from(query.getViewNodes())) {
        if (organisable(n)) {
          const opath = n.getType().name === 'Organism' ? n : n.append('organism');
          result2.push(opath.append('shortName'));
        }
      }
      return result2;
    })();

    if (newView.length) {
      return query.clone()
           .select(_.uniq(newView, String))
           .orderBy([])
           .rows()
           .then(done, nothing);
    } else {
      return nothing();
    }
  }
}) );

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}