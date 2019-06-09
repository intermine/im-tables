/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
//# Requires @query :: Query, @view :: PathInfo
//# sets @state{typeName, pathName, endName, error}
exports.setPathNames = function() {
  const q = (this.query != null ? this.query : this.model.query);
  const v = (this.view != null ? this.view : this.model.view);
  const { service } = q;
  const type = v.getParent().getType();
  const { end } = v;
  const s = this.state;
  const set = prop => val => s.set(prop, val);
  const setError = set('error');
  v.getDisplayName().then((set('pathName')), setError);
  type.getDisplayName().then((set('typeName')), setError);
  return service.get(`model/${ type.name }/${ end.name }`)
         .then(({name}) => name) // cf. {display}
         .then((set('endName')), setError);
};
