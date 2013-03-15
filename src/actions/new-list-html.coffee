define 'html/new-list', -> """
  <div class="modal im-list-creation-dialogue">
      <div class="modal-header">
          <a class="close btn-cancel">close</a>
          <h2>List Details</h2>
      </div>
      <div class="modal-body">
          <form class="form form-horizontal">
              <p class="im-list-summary"></p>
              <fieldset class="control-group">
                  <label>Name</label>
                  <input class="im-list-name input-xlarge" type="text" placeholder="required identifier">
                  <span class="help-inline"></span>
              </fieldset>
              <fieldset class="control-group">
                  <label>Description</label>
                  <input class="im-list-desc input-xlarge" type="text" placeholder="an optional description" >
              </fieldset>
              <fieldset class="control-group im-tag-options">
                  <label>Add Tags</label>
                  <input type="text" class="im-available-tags input-medium" placeholder="categorize your list">
                  <button class="btn im-confirm-tag" disabled>Add</button>
                  <ul class="im-list-tags choices well">
                      <div style="clear:both"></div>
                  </ul>
                  <h5><i class="icon-chevron-down"></i>Suggested Tags</h5>
                  <ul class="im-list-tags suggestions well">
                      <div style="clear:both"></div>
                  </ul>
              </fieldset>
              <input type="hidden" class="im-list-type">
          </form>
          <div class="alert alert-info im-selection-instruction">
              <b>Get started!</b> Choose items from the table below.
              You can move this dialogue around by dragging it, if you 
              need access to a column it is covering up.
          </div>
      </div>
      <div class="modal-footer">
          <div class="btn-group">
              <button class="btn btn-primary">Create</button>
              <button class="btn btn-cancel">Cancel</button>
              <button class="btn btn-reset">Reset</button>
          </div>
      </div>
  </div>
"""

