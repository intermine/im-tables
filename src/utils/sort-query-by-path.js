/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let sortQueryByPath;
const NEXT_DIRECTION_OF = {
  ASC: 'DESC',
  DESC: 'ASC',
  NONE: 'ASC'
};

module.exports = (sortQueryByPath = function(query, path) {
  let left;
  const currentDirection = ((left = query.getSortDirection(path)) != null ? left : 'NONE');
  const nextDirection = NEXT_DIRECTION_OF[currentDirection];
  return query.orderBy([{path, direction: nextDirection}]);
});

