// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
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
