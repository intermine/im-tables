module.exports = function(fields) { if (fields == null) { fields = []; } return model => fields.every(f => model.has(f)); };
