/*
 * decaffeinate suggestions:
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let Page;
module.exports = (Page = class Page {

  // Build a new page
  // @param start [Natural] The start index (start != null && start >= 0)
  // @param size [Natural?] the size of the page (size == null || size >= 0)
  constructor(start, size = null) {
    this.start = start;
    this.size = size;
    if ((this.start == null) || !(this.start >= 0)) { throw new Error('Start must be >= 0'); }
    if ((this.size != null) && (this.size < 0)) { throw new Error('Size must be null or Natural'); }
  }

  // Get the end of this page (the index one past the last index)
  // eg. for Page(0, 10) the end is 10
  //     for Page(0) the end is null
  end() { if (this.all()) { return null; } else { return this.start + this.size; } }

  // Is this page unbounded to the right? True if size == null or size === 0
  all() { return !this.size; }

  // Is this page fully to the left of the given zero-based index?
  isBefore(index) { return (this.size != null) && (this.end() < index); }

  // Is this page fully to the right of the given zero-based index?
  isAfter(index) { return index < this.start; }

  // How many spaces are there between the given index and this page, on the left?
  // eg. let this = new Page(10, 10) then leftGap 8 = 2
  //     let this = new Page(10, 10) then leftGap 10 = null
  //     let this = new Page(10, 10) then leftGap 12 = null
  leftGap(index) { if (this.isAfter(index)) { return this.start - index; } else { return null; } }

  // How many spaces are there between the given index and this page, on the right?
  // eg. let this = new Page(10, 10) then leftGap 8 = null
  //     let this = new Page(10, 10) then leftGap 20 = null
  //     let this = new Page(10, 10) then leftGap 22 = 2
  rightGap(index) { if (this.isBefore(index)) { return index - this.end(); } else { return null; } }

  // Get the page after this page.
  next() { return new Page(this.end(), this.size); }

  // Get the page before this page.
  prev() { return new Page((Math.max(0, this.start - this.size)), this.size); }

  // Get a string representation of this page, eg. "Page(10 .. 20)"
  toString() { return `Page(${ this.start } .. ${ this.end() })`; }
});
