// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const $ = require('jquery');

const centre = function(el) {
  const $body = $('body');
  const bwidth = $body.width();
  const ewidth = el.width();
  return el.css({
    left: (bwidth - ewidth) / 2,
    top: 50
  });
};

// We override the modal hide/show mechanism because we want this dialogue to
// not have a back-drop and be draggable.
exports._showModal = function() {
  const el = this.$el;
  el.modal({show: false}) // we do the showing ourselves in this case.
    .addClass('im-floating')
    .draggable({handle: '.modal-header'})
    .show(function() {
      centre(el);
      return el.animate({opacity: 1}, {complete() { return el.addClass('in'); }});
  });
      
  return this.listenToOnce(this, 'remove', () => this.$el.draggable('destroy'));
};

exports._hideModal = function() {
  // @$el.modal('hide') does nothing, since we never call show.
  this.$el.removeClass('in');
  return this.onHidden();
};

