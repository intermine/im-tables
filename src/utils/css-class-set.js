let ClassSet;
const _ = require('underscore');

module.exports = (ClassSet = class ClassSet {

  constructor(definitions) {
    this.definitions = definitions;
  }

  activeClasses() { return ((() => {
    const result = [];
    for (let cssClass in this.definitions) {
      if (_.result(this.definitions, cssClass)) {
        result.push(cssClass);
      }
    }
    return result;
  })()); }

  toString() { return this.activeClasses().join(' '); }
});

