// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
let ModalBody;
const View = require('../../core-view');

// Just make sure that the bodies have access to the query.
module.exports = (ModalBody = class ModalBody extends View {

  initialize({query}) { this.query = query; return super.initialize(...arguments); }
});
