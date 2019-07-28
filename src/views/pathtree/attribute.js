// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let Attribute;
const _ = require('underscore');
const View = require('../../core-view');

const Options = require('../../options');
const Icons = require('../../icons');

/*
 * Type expectations:
 *  - @chosenPaths :: UniqItems
 *  - @model :: CoreModel {multiSelect}
 *  - @trail :: [PathInfo]
 *  - @query :: Query
 *  - @path :: PathInfo
 *
 */

const notBlank = s => (s != null) && /\w/.test(s);

const stripLeadingSegments = name => name != null ? name.replace(/^.*\s*>/, '') : undefined;

const highlightMatch = match => `<strong>${ match }</strong>`;

module.exports = (Attribute = (function() {
  Attribute = class Attribute extends View {
    static initClass() {
  
      this.prototype.tagName = 'li';
  
      this.prototype.template = _.template(`\
<a href="#" title="<%- title %>">
  <%= icon %>
  <span>
    <%= name %>
  </span>
</a>\
`
      );
    }

    events() {
      return {'click a': 'handleClick'};
    }

    initialize({chosenPaths, view, query, path, trail}) {
      this.chosenPaths = chosenPaths;
      this.view = view;
      this.query = query;
      this.path = path;
      this.trail = trail;
      super.initialize(...arguments);
      this.depth = this.trail.length + 1;
      this.state.set({
        visible: true,
        highlitName: null,
        name: this.path.toString()
      });

      this.listenTo(this.chosenPaths, 'add remove reset', this.handleChoice);
      this.listenTo(this.state, 'change:visible', this.onChangeVisible);
      this.listenTo(this.state, 'change:highlitName', this.render);
      this.listenTo(this.state, 'change:displayName', this.render);

      return this.path.getDisplayName().then(displayName => {
        return this.state.set({displayName, name: stripLeadingSegments(displayName)});
    });
    }

    onChangeVisible() { return this.$el.toggle(this.state.get('visible')); }

    getFilterPatterns() {
      const filterTerms = this.model.get('filter');
      if (notBlank(filterTerms)) {
        return (Array.from(filterTerms.split(/\s+/)).filter((t) => t).map((t) => new RegExp(t, 'i')));
      } else {
        return [];
      }
    }

    handleClick(e) {
      e.stopPropagation();
      e.preventDefault();

      if ((this.model.get('dontSelectView')) && (this.view != null ? this.view.contains(this.path) : undefined)) {
        return;
      }

      if (this.chosenPaths.contains(this.path)) {
        return this.chosenPaths.remove(this.path);
      } else {
        return this.choose();
      }
    }

    choose() { // Depending on the selection mode, either add this, or select just this.
      if (this.model.get('multiSelect')) {
        return this.chosenPaths.add(this.path);
      } else {
        return this.chosenPaths.reset([this.path]);
      }
    }

    handleChoice() {
      return this.$el.toggleClass('active', this.chosenPaths.contains(this.path));
    }

    setHighlitName(regexps) { // Set now if available, or wait until it is.
      if (this.state.has('name')) {
        return this.state.set({highlitName: this.getHighlitName(regexps)});
      } else {
        return this.state.once('change:name', () => {
          return this.state.set({highlitName: this.getHighlitName(regexps)});
        });
      }
    }

    getHighlitName(regexps) {
      const name = this.state.get('name');
      const pathName = this.path.end != null ? this.path.end.name : undefined;
      let highlit = name;

      for (let r of Array.from(regexps)) {
        highlit = highlit.replace(r, highlightMatch);
      }

      if (/strong/.test(highlit)) {
        return highlit;
      } else {
        return highlightMatch(highlit); // Highlight it all.
      }
    }

    getDisabled() { return false; }

    getData() {
      const title = Options.get('ShowId') ? `${ this.path } (${ this.path.getType() })` : '';
      const name = this.state.get('highlitName') ? this.state.get('highlitName') : this.state.escape('name');
      const icon = Icons.icon('Attribute');
      return {icon, title, name};
    }

    render() {
      super.render(...arguments);
      this.$el.toggleClass('disabled', this.getDisabled());
      if (Options.get('ShowId')) {
        this.$('a').tooltip({placement: 'bottom'});
      }
      this.handleChoice();
      if (this.view != null) {
        this.$el.toggleClass('in-view', this.view.contains(this.path));
      }
      return this;
    }
  };
  Attribute.initClass();
  return Attribute;
})());
