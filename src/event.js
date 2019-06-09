// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
// Simple event that can be passed to handlers for cancellable events.
let Event;
module.exports = (Event = class Event {

  constructor(data, target) {
    this.data = data;
    this.target = target;
  }

  cancel() { return this.cancelled = true; }

  preventDefault() { return this.cancel(); }

  stopPropagation() {} // no-op
});
