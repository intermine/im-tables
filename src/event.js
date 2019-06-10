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
