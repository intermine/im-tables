let FormattedSorting;
const CoreView = require('../core-view');
const Templates = require('../templates');
const SortedPath = require('./formatted/sorting-path');

const sortQueryByPath = require('../utils/sort-query-by-path');

// A class that handles the machinery for letting users choose which column
// to sort by when a column represents multiple paths due to formatting.
module.exports = (FormattedSorting = (function() {
  FormattedSorting = class FormattedSorting extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-col-sort-menu no-margins';
  
      this.prototype.tagName = 'ul';
    }

    initialize({query}) {
      this.query = query;
      super.initialize(...arguments);
      return this.setPathNames(); // initialise the path display name dictionary
    }

    modelEvents() {
      return {
        'change:displayName': this.initState,
        'change:replaces': this.setPathNames
      };
    }

    initState() {
      return this.state.set({group: this.model.get('displayName')});
    }

    // in this class we make use of the state as a path display name lookup
    // dictionary which means we also need to make sure we have an entry of
    // each of them.
    setPathNames() { return Array.from(this.getPaths()).map((p) => (p => {
      const key = p.toString();
      if (!this.state.has(key)) { this.state.set(key, ''); }
      return p.getDisplayName().then(name => this.state.set(key, name));
    })(p)); }

    // :: [PathInfo]
    getPaths() {
      const replaces = this.model.get('replaces');
      if (replaces.length) {
        return replaces.slice();
      } else {
        return [this.query.makePath(this.model.get('path'))];
      }
    }

    preRender(e) {
      let paths;
      const [path] = Array.from((paths = this.getPaths()));   // find the paths, and extract the first one.
      if (paths.length === 1) {           // Nothing for the user to choose from
        e.cancel();                   // cancels impending render.
        return sortQueryByPath(this.query, path); // sort on the first (and only) path
      }
    }

    // templateless render - it is all about the child views.
    postRender() { return Array.from(this.getPaths()).map((p, i) =>
      this.renderChild(i, (new SortedPath({model: this.model, state: this.state, query: this.query, path: p})))); }
  };
  FormattedSorting.initClass();
  return FormattedSorting;
})());

