const _ = require('underscore');

const CACHE = {};

// Mixin method that runs a query, defined by @query and the values of @model
exports.runQuery = function(overrides) {
  if (overrides == null) { overrides = {}; }
  const params = this.getExportParameters(overrides);
  const key = `results:${ this.query.service.root }:${ JSON.stringify(params) }`;
  let endpoint = 'query/results';
  const format = this.model.get('format');
  // Custom formats have custom endpoints.
  if (format.needs != null ? format.needs.length : undefined) { endpoint += `/${ format.id }`; }
  return CACHE[key] != null ? CACHE[key] : (CACHE[key] = this.query.service.post(endpoint, params));
};

exports.getEstimatedSize = function() {
  const q = this.getExportQuery();
  const key = `count:${ q.service.root }:${ q.toXML() }`;
  return CACHE[key] != null ? CACHE[key] : (CACHE[key] = q.count());
};

exports.getExportQuery = function() {
  const toRun = this.query.clone();
  const columns = this.model.get('columns');
  if (columns != null ? columns.length : undefined) {
    toRun.select(columns);
  }
  return toRun;
};

exports.getExportURI = function(overrides) {
  return this.getExportQuery().getExportURI(this.model.get('format').id, this.getExportParameters(overrides));
};

exports.getFileName = function() { return `${ this.getBaseName() }.${ this.getFileExtension() }`; };

exports.getBaseName = function() { return this.model.get('filename'); };

exports.getFileExtension = function() { return this.model.get('format').ext; };

exports.getExportParameters = function(overrides) {
  if (overrides == null) { overrides = {}; }
  const data = this.model.pick('start', 'size', 'format', 'filename');
  data.format = data.format.id;
  data.query = this.getExportQuery().toXML();
  if (this.model.get('compress')) {
    data.compress = this.model.get('compression');
  }
  if (this.model.get('headers')) {
    data.columnheaders = this.model.get('headerType');
  }
  // TODO - this is hacky - the model should reflect the request
  if ((data.format === 'json') && ('rows' !== this.model.get('jsonFormat'))) {
    data.format += this.model.get('jsonFormat');
  }
  if ((data.format === 'fasta') && (this.model.get('fastaExtension'))) {
    data.extension = this.model.get('fastaExtension');
  }
  if ((data.format === 'fasta') || (data.format === 'gff3')) {
    data.view = this.model.get('columns');
  }
  return _.extend(data, overrides);
};
