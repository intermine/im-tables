scope 'intermine.columns.snippets',
  ColumnsDialogue: """
    <div class="modal-header">
      <a class="close" data-dismiss="modal">close</a>
      <h3>Manage Columns</a>
    </div>
    <div class="modal-body">
      <ul class="nav nav-tabs">
        <li class="active">
          <a data-target=".im-reordering" data-toggle="tab">
            #{ intermine.messages.columns.OrderTitle }
          </a>
        </li>
        <li>
          <a data-target=".im-sorting" data-toggle="tab">
            #{ intermine.messages.columns.SortTitle }
          </a>
        </li>
      </ul>
      <div class="tab-content">
        <div class="tab-pane fade im-reordering active in">
          <div class="node-adder"></div>
          <div class="well">
          <ul class="im-reordering-container nav nav-tabs nav-stacked"></ul>
          </div>
        </div>
        <div class="tab-pane fade im-sorting">
          <div class="well">
          <ul class="im-sorting-container nav nav-tabs nav-stacked"></ul>
          </div>
          <form class="form-search">
          <i class="#{ intermine.icons.Help } pull-right im-sorting-help"></i>
          <div class="input-prepend">
            <span class="add-on">filter</span>
            <input type="text" class="search-query im-sortables-filter">
          </div>
          <label class="im-only-in-view">
            #{ intermine.messages.columns.OnlyColsInView }
            <input class="im-only-in-view" type="checkbox" checked>
          </label>
          </form>
          <div class="well">
          <ul class="im-sorting-container-possibilities nav nav-tabs nav-stacked"></ul>
          </div>
        </div>
      </div>
    </div>
    <div class="modal-footer">
      <a class="btn btn-cancel">
        Cancel
      </a>
      <a class="btn pull-right btn-primary">
        Apply
      </a>
    </div>
    """
