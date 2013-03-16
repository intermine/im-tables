define 'html/append-list', -> """
  <div class="modal">
    <div class="modal-header">
      <a class="close btn-cancel">close</a>
      <h2>Add Items To Existing List</h2>
    </div>
    <div class="modal-body">
      <form class="form-horizontal form">
        <fieldset class="control-group">
          <label>
            Add
            <span class="im-item-count"></span>
            <span class="im-item-type"></span>
            to:
            <select class="im-receiving-list input-xlarge">
                <option value=""><i>Select a list</i></option>
            </select>
          </label>
          <span class="help-inline"></span>
        </fieldset>
      </form>
      <div class="alert alert-error im-none-compatible-error">
        <b>Sorry!</b> You don't have access to any compatible lists.
      </div>
      <div class="alert alert-info im-selection-instruction">
        <b>Get started!</b> Choose items from the table below.
        You can move this dialogue around by dragging it, if you 
        need access to a column it is covering up.
      </div>
    </div>
    <div class="modal-footer">
      <div class="btn-group">
        <button disabled class="btn btn-primary">Add to list</button>
        <button class="btn btn-cancel">Cancel</button>
      </div>
    </div>
  </div>
"""
