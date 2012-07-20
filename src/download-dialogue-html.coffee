scope 'intermine.snippets.actions', {
    DownloadDialogue: -> """
        <a class="btn im-open-dialogue" href="#">
            <i class="#{ intermine.icons.Export }"></i>
            #{ intermine.messages.actions.ExportButton }
        </a>
        <div class="modal fade">
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
                            <button class="btn active im-all-cols span5">
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
                        <div class="alert alert-info">
                            <button class="close" data-dismiss="alert">×</button>
                            <strong>ps</strong>
                            <p>#{ intermine.messages.actions.ChangeColumns }</p>
                        </div>
                    </div>
                    </div>
                    <div class="row-fluid">
                    <label title="#{ intermine.messages.actions.RowsHelp }">
                        <span class="span4">
                            #{ intermine.messages.actions.WhichRows }
                            </span>
                        <div class="im-row-btns radio span8 btn-group pull-right" data-toggle="buttons-radio">
                            <button class="btn active im-all-rows span5">#{ intermine.messages.actions.AllRows }</button>
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
                    <div class="row-fluid">
                    <fieldset class="im-export-options control-group">
                    </fieldset>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button class="btn btn-primary pull-right" title="#{ intermine.messages.actions.ExportHelp }">
                    #{ intermine.messages.actions.Export }
                </button>
                <div class="btn-group btn-alt pull-right">
                    <a href="#" class="btn btn-galaxy" title="#{intermine.messages.actions.GalaxyHelp}">
                        #{ intermine.messages.actions.SendToGalaxy }
                    </a>
                    <a href="#" title="#{intermine.messages.actions.GalaxyAlt}" 
                        class="btn dropdown-toggle galaxy-toggle" data-toggle="dropdown">
                        <span class="caret"></span>
                    </a>
                </div>
                <button class="btn btn-cancel pull-left">
                    #{ intermine.messages.actions.Cancel }
                </button>
                <form class="well form-inline im-galaxy-options">
                    <label>
                        #{ intermine.messages.actions.GalaxyURILabel }
                        <input type="text" class="im-galaxy-uri input-xlarge" 
                            value="#{ intermine.options.GalaxyMain }">
                    </label>
                    <button type="submit" class="btn">
                        #{ intermine.messages.actions.SendToOtherGalaxy }
                    </button>
                    <div class="alert alert-info">
                        <button class="close" data-dismiss="alert">×</button>
                        <strong>ps</strong>
                        #{ intermine.messages.actions.GalaxyAuthExplanation }
                    </div>
                </form>
            </div>
        </div>
    """
}
