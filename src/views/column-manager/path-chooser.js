/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ColumnChooser;
const CoreView = require('../../core-view');
const Templates = require('../../templates');
const Options = require('../../options');

const PathSet = require('../../models/path-set');
const OpenNodes = require('../../models/open-nodes');

const PathChooser = require('../path-chooser');

class Buttons extends CoreView {
  static initClass() {
  
    this.prototype.parameters = ['collection', 'selectList'];
  
    this.prototype.template = Templates.template('column-manager-path-chooser-buttons');
  }

  collectionEvents() {
    return {'add remove reset': 'reRender'};
  }

  events() {
    return {
      'click .im-add-column': 'addColumn',
      'click .im-rearrange-columns': 'cancel'
    };
  }

  cancel() {
    return this.trigger('done');
  }
  
  addColumn() {
    const { selectList } = this;
    const paths = this.collection.paths();
    this.cancel();
    return selectList.add(paths);
  }
}
Buttons.initClass();

module.exports = (ColumnChooser = (function() {
  ColumnChooser = class ColumnChooser extends CoreView {
    static initClass() {
  
      this.prototype.parameters = ['query', 'collection'];
  
      this.prototype.template = Templates.template('column-manager-path-chooser');
    }

    initialize() {
      super.initialize(...arguments);
      this.chosenPaths = new PathSet;
      this.view = new PathSet(Array.from(this.collection.pluck('path')).map((p) => this.query.makePath(p)));
      return this.openNodes = new OpenNodes(this.query.getViewNodes()); // Open by default
    }

    initState() {
      return this.query.makePath(this.query.root).getDisplayName().then(name => this.state.set({rootName: name}));
    }

    stateEvents() {
      return {'change:rootName': 'reRender'};
    }

    postRender() {
      this.renderButtons();
      return this.openPathChooser();
    }

    renderButtons() {
      const btns = new Buttons({state: this.state, collection: this.chosenPaths, selectList: this.collection});
      this.listenTo(btns, 'done', () => this.trigger('done'));
      return this.renderChildAt('.btn-group', btns);
    }

    openPathChooser() {
      const model = {
        dontSelectView: true,
        multiSelect: (Options.get('ColumnManager.SelectColumn.Multi'))
      };
      const pathChooser = new PathChooser({model, query: this.query, chosenPaths: this.chosenPaths, openNodes: this.openNodes, view: this.view, trail: []});
      this.renderChild('pathChooser', pathChooser);
      return this.setPathChooserHeight();
    }

    setPathChooserHeight() { // Don't let it get too big.
      return this.$('.im-path-chooser').css({'max-height': (this.$el.closest('.modal').height() - 350)});
    }

    remove() {
      this.chosenPaths.close();
      this.view.close();
      this.openNodes.close();
      return super.remove(...arguments);
    }
  };
  ColumnChooser.initClass();
  return ColumnChooser;
})());

