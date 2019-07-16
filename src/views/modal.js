let Modal;
const {Promise} = require('es6-promise');
const _ = require('underscore');
const View = require('../core-view');
const Messages = require('../messages');
const Templates = require('../templates');

const modalTemplate = Templates.template('modal_base');

const ModalFooter = require('./modal-footer');

module.exports = (Modal = (function() {
  Modal = class Modal extends View {
    static initClass() {
  
      this.prototype.Footer = ModalFooter;
  
      // Override to customise the footer.
      this.prototype.footer = Templates.templateFromParts(['modal_error', 'modal_footer']);
  
      this.prototype.shown = false;
    }

    className() { return 'modal fade'; }

    initialize() {
      super.initialize(...arguments);
      // Create a promise and capture its resolution controls.
      this._promise = new Promise((resolve, reject) => {
        this.resolve = resolve;
        this.reject = reject;
        
    });
      return this.listenTo(this.state, 'change', this.renderFooter);
    }

    resolve() { throw new Error('resolved before initialisation'); }

    reject() { throw new Error('rejected before initialisation'); }

    dismissError() { // remove the error, gracefully.
      return this.$('.modal-footer .alert').slideUp(250, () => this.state.set({error: null}));
    }

    events() {
      return {
        'click .modal-footer .alert .dismiss': 'dismissError', // Dismiss error
        'click .modal-footer .btn-cancel': 'hide', // Establish a convention for closing modals.
        'click .modal-footer button.btn-primary': 'act', // Establish a convention for acting.
        'hidden.bs.modal': 'onHidden', // Can be caused by user clicking off the modal.
        'click .close': 'hide' // Establish a convention for closing modals.
      };
    }

    promise() { return this._promise; }

    hide() { return this.resolve('dismiss'); }

    // Override this to make the modal *do* something.
    act() { throw new Error('Not implemented.'); }

    primaryIcon() { return null; }

    renderFooter() {
      if (!this.rendered) { return; }
      const dismissAction = _.result(this, 'dismissAction');
      const primaryAction = _.result(this, 'primaryAction');
      const primaryIcon = _.result(this, 'primaryIcon');
      const opts = {
        template: this.footer,
        model: this.state,
        actionNames: {dismissAction, primaryAction},
        actionIcons: {primaryIcon}
      };
      return this.renderChild('footer', (new this.Footer(opts)), this.$('.modal-content'));
    }

    postRender() {
      return this.renderFooter();
    }

    onHidden(e) {
      if ((e != null) && (e.target !== this.el)) { // ignore bubbled events from sub-dialogues.
        return false;
      }
      this.resolve('dismiss'); // User has dismissed this modal.
      this.shown = false;
      return this.remove();
    }

    remove() {
      // While this looks dangerous (since rejection triggers removal), it in fact can
      // cause no more than one nested call since rejection is a no-op if the promise is
      // already resolved or rejected.
      this.reject(new Error('unresolved before removal'));

      // Allow removal and hiding to go together.
      // note that we return here to avoid infinite recursion, since hiding triggers removal.
      if (this.shown) { return this._hideModal(); }

      return super.remove();
    }

    // Override these to provide better text. Can be function or value. You should
    // always override title and primaryAction
    title() { return Messages.getText('modal.DefaultTitle'); }
    dismissAction() { return Messages.getText('modal.Dismiss'); }
    primaryAction() { return Messages.getText('modal.OK'); }
    modalSize() {}

    // Override to provide the modal body. Not required if loading child components.
    body() {}

    // Can be used to update the title. Calling reRender will stuff up the modal.
    renderTitle() { if (this.rendered) {
      return this.$('.modal-title').text(_.result(this, 'title'));
    } }

    // Use this to make use of the default modal structure.
    template(data) {
      const title = _.result(this, 'title');
      const body = this.body(data);
      const modalSize = `modal-${ _.result(this, 'modalSize') }`;
      return modalTemplate({title, body, modalSize});
    }

    // Can be called multiple times, and called on re-render.
    // @return [Promise<String>] A promise resolved with the name of an action to take.
    show() {
      const p = this.promise();
      p.then((() => this.remove()), (() => this.remove()));

      try {
        this._showModal();
        this.trigger('shown', (this.shown = true));
      } catch (e) {
        this.reject(e);
      }

      return p;
    }

    // Actually show the modal dialogue. Override to customise.
    // This is a protected method - if you are not a modal yourself, do not call this method.
    _showModal() { return this.$el.modal().modal('show'); }

    // Actually hide the modal dialogue. Override to customise.
    // This is a protected method - if you are not a modal yourself, do not call this method.
    _hideModal() { return this.$el.modal('hide'); }
  };
  Modal.initClass();
  return Modal;
})());
