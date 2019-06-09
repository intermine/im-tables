/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Very simple extension of renderChild that also calls show on
// the dialogue. Also all dialogues have the same name because
// there should only be one at a time.
//
// A part of this protocol (not mandatory) is that the dialogue::show
// method should return a promise for the resolution of the dialogue as
// a whole.
exports.openDialogue = function(dialogue) { 
  this.renderChild('__dialogue__', dialogue);
  return dialogue.show();
};

// Convenience method to get the current dialogue.
exports.getDialogue = function() { return (this.children != null ? this.children.__dialogue__ : undefined); };

