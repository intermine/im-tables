NEXT_DIRECTION_OF =
  ASC: 'DESC'
  DESC: 'ASC'
  NONE: 'ASC'

module.exports = sortQueryByPath = (query, path) ->
  currentDirection = (query.getSortDirection(path) ? 'NONE')
  nextDirection = NEXT_DIRECTION_OF[currentDirection]
  query.orderBy {path, direction: nextDirection}

