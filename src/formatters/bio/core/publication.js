define('formatters/bio/core/publication', function() {

  const PublicationFormatter = function(imobject) {
    const id = imobject.get('id');
    this.$el.addClass('publication');
    if (!imobject.has('title') || !imobject.has('firstAuthor') || !imobject.has('year')) {
      if (imobject.__fetching == null) { imobject.__fetching = this.model.get('query').service.findById('Publication', id); }
      imobject.__fetching.then(pub => imobject.set(pub));
    }

    const {title, firstAuthor, year} = imobject.toJSON();
    return `${title} (${firstAuthor}, ${year})`;
  };

  PublicationFormatter.replaces = [ 'title', 'firstAuthor', 'year' ];

  return PublicationFormatter;
});
