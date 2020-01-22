module.exports = (fields = []) -> (model) -> fields.every (f) -> model.has f
