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

