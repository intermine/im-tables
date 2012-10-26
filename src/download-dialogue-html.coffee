scope 'intermine.snippets.actions', {
    DownloadDialogue: -> """
        <a class="btn im-open-dialogue" href="#">
            <i class="#{ intermine.icons.Export }"></i>
            #{ intermine.messages.actions.ExportButton }
        </a>
        <div class="modal fade" style="overflow-x:visible;overflow-y:visible">
            <div class="modal-header">
                <a class="close btn-cancel">close</a>
                <h2>#{ intermine.messages.actions.ExportTitle }</h2>
            </div>
            <div class="modal-body">
                <form class="form">
                    <div class="row-fluid">
                    <label>
                        <span class="span4">
                            #{ intermine.messages.actions.ExportFormat }
                        </span>
                        <select class="im-export-format input-xlarge span8">
                        </select>
                    </label>
                    </div>
                    <div class="row-fluid">
                    <label title="#{ intermine.messages.actions.ColumnsHelp }">
                        <span class="span4">
                            #{ intermine.messages.actions.WhichColumns }
                        </span>
                        <div class="im-col-btns radio btn-group pull-right span8">
                            <button class="btn active im-all-cols span6">
                                #{ intermine.messages.actions.AllColumns }
                            </button>
                            <button class="btn span5">
                                #{ intermine.messages.actions.SomeColumns }
                            </button>
                        </div>
                    </label>
                    <div class="im-col-options">
                        <ul class="well im-cols im-can-be-exported-cols">
                            <h4>#{ intermine.messages.actions.PossibleColumns }</h4>
                        </ul>
                        <ul class="well im-cols im-exported-cols">
                            <h4>#{ intermine.messages.actions.ExportedColumns }</h4>
                        </ul>
                        <div style="clear:both;"></div>
                        <button class="im-reset-cols btn disabled">
                            <i class="#{ intermine.icons.Undo }"></i>
                            #{ intermine.messages.actions.ResetColumns }
                        </button>
                    </div>
                    </div>
                    <div class="row-fluid">
                    <label title="#{ intermine.messages.actions.RowsHelp }">
                        <span class="span4">
                            #{ intermine.messages.actions.WhichRows }
                            </span>
                        <div class="im-row-btns radio span8 btn-group pull-right" data-toggle="buttons-radio">
                            <button class="btn active im-all-rows span6">#{ intermine.messages.actions.AllRows }</button>
                            <button class="btn span5">#{ intermine.messages.actions.SomeRows }</button>
                        </div>
                    </label>
                    <div class="form-horizontal">
                        <fieldset class="im-row-selection control-group">
                            <label class="control-label">
                                #{ intermine.messages.actions.FirstRow }
                                <input type="text" value="1" class="disabled input-mini im-first-row im-range-limit">
                            </label>
                            <label class="control-label">
                                #{ intermine.messages.actions.LastRow }
                                <input type="text" class="disabled input-mini im-last-row im-range-limit">
                            </label>
                            <div style="clear:both"></div>
                            <div class="slider im-row-range-slider"></div>
                        </fieldset>
                    </div>
                    </div>
                    <fieldset class="control-group">
                        <label>
                            <span class="span4">
                                #{ intermine.messages.actions.CompressResults }
                            </span>
                            <div class="span8 im-compression-opts radio btn-group pull-right" data-toggle="buttons-radio">
                                    <button class="btn active im-no-compression span7">
                                        #{ intermine.messages.actions.NoCompression }
                                    </button>
                                    <button class="btn im-gzip-compression span2">
                                        #{ intermine.messages.actions.GZIPCompression }
                                    </button>
                                    <button class="btn im-zip-compression span2">
                                        #{ intermine.messages.actions.ZIPCompression }
                                    </button>
                            </div>
                        </label>
                    </fieldset>
                    <div class="row-fluid">
                    <fieldset class="im-export-options control-group">
                    </fieldset>
                    </div>
                </form>
            </div>
            <div class="modal-footer" style="overflow-x:visible;overflow-y:visible">
                <div class="btn-group pull-right">
                    <button class="btn btn-primary im-download pull-right" title="#{ intermine.messages.actions.ExportHelp }">
                        <i class="icon #{ intermine.icons.Export }"></i>
                        #{ intermine.messages.actions.Export }
                    </button>
                    <button class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu">
                        <li>
                            <a href="#" class="im-download" title="#{ intermine.messages.actions.ExportHelp }">
                                #{ intermine.messages.actions.ExportLong }
                            </a>
                        </li>
                        <li class="divider"></li>
                        <li>
                            <a href="#" class="im-send-to-galaxy">
                                #{ intermine.messages.actions.SendToGalaxy }
                            </a>
                            <form class="form form-compact well">
                                <label>
                                    #{ intermine.messages.actions.GalaxyURILabel }
                                    <input class="im-galaxy-uri" type="text" value="#{ intermine.options.GalaxyMain }">
                                </label>
                                <label>
                                    #{ intermine.messages.actions.SaveGalaxyURL }
                                    <input type="checkbox" disabled checked class="im-galaxy-save-url">
                                </label>
                            </form>
                        </li>
                        <li>
                            <a target="blank" href="#{ intermine.messages.actions.WhatIsGalaxyURL }">
                                <i class="icon icon-question-sign"></i>
                                #{ intermine.messages.actions.WhatIsGalaxy }
                            </a>
                        </li>
                    </ul>
                </div>
                <div class="btn-group pull-right">
                    <button class="btn im-perma-link dropdown-toggle" data-toggle="dropdown"
                       title="#{ intermine.messages.actions.ResultsPermaLinkTitle }">
                        <i class="icon icon-link"></i>
                    </button>
                    <ul class="dropdown-menu">
                        <li>
                            <div class="well im-perma-link-content">
                            </div>
                            <div class="alert alert-block im-private-query">
                                <button type="button" class="close" data-dismiss="alert">×</button>
                                <h4>nb:</h4>
                                #{ intermine.messages.actions.IsPrivateData }
                            </div>
                        </li>
                    </ul>
                </div>
                <div class="btn-group pull-right im-ws-v12">
                    <button class="btn im-perma-link-share dropdown-toggle" data-toggle="dropdown"
                       title="#{ intermine.messages.actions.ResultsPermaLinkShareTitle }">
                        <i class="icon icon-group"></i>
                    </button>
                    <ul class="dropdown-menu">
                        <li>
                            <div class="well im-perma-link-share-content">
                            </div>
                        </li>
                    </ul>
                </div>
                <button class="btn btn-cancel pull-left">
                    #{ intermine.messages.actions.Cancel }
                </button>
            </div>
        </div>
    """
}
