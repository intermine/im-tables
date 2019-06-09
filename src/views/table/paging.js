/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Mix-In for views that need to do paging.
// Requires: this.model :: Model with the structure {size, start, count}
// Provides: {getMaxPage, goTo, goToPage, goBack, goForward}

exports.getCurrentPage = function() {
  const {start, size} = this.model.toJSON();
  return Math.floor(start/size) + 1;
};

exports.getMaxPage = function() {
  const {count, size} = this.model.toJSON();
  const correction = (count % size) === 0 ? 0 : 1;
  return Math.floor(count / size) + correction;
};

exports.goTo = function(start) {
  return this.model.set({start});
};

// Go to a 1-indexed page.
exports.goToPage = function(page) {
  return this.model.set({start: ((page - 1) * this.model.get('size'))});
};

exports.goBack = function(pages) {
  const {start, size} = this.model.toJSON();
  return this.goTo(Math.max(0, start - (pages * size)));
};

exports.goForward = function(pages) {
  const {start, size} = this.model.toJSON();
  return this.goTo(Math.min(this.getMaxPage() * size, start + (pages * size)));
};
