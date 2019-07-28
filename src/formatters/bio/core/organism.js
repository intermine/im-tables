define('formatters/bio/core/organism', function() {

  let Organism;
  const getData = function(model, prop, backupProp) {
    const ret = {};
    const val = (ret[prop] = model.get(prop));
    if (val == null) {
      ret[prop] = model.get(backupProp);
    }
    return ret;
  };

  const ensureData = function(model, service) {
    let p;
    if ((model._fetching != null) || model.has('shortName')) { return; }
    model._fetching = (p = service.findById('Organism', model.get('id')));
    return p.done(org => model.set({shortName: org.shortName}));
  };

  const templ = _.template("<span class=\"name\"><%- shortName %></span>");

  return Organism = function(model) {
    this.$el.addClass('organism');
    ensureData(model, this.model.get('query').service);

    if (model.get('id')) {
      const data = getData(model, 'shortName', 'name');
      return templ(data);
    } else {
      return "<span class=\"null-value\">&nbsp;</span>";
    }
  };
});

