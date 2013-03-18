do ->
  DownloadDialogue = -> """

    <div class="modal-header">
      <a href="#" class="close" data-dismiss="modal">close</a>
      <h2>
        #{ intermine.messages.actions.ExportTitle }
      </h2>
    </div>

    <div class="modal-body tab-content">
     <div class="carousel slide">
      <div class="carousel-inner">
      <div class="active item">

       <div class="tabbable tabs-left">
         <ul class="nav nav-tabs">
           <li class="active">
             <a href="#" class="im-export-format">format</a>
           </li>
           <li>
             <a href="#" class="im-export-columns">columns</a>
           </li>
           <li>
             <a href="#" class="im-export-rows">Rows</a>
           </li>
           <li>
             <a href="#" class="im-export-output">Output</a>
           </li>
           <li>
             <a href="#" class="im-export-destination">Destination</a>
           </li>
         </ul>
         <div class="tab-content">
           <div class="tab-pane active im-export-format">
              <h2>
                #{ intermine.messages.actions.ExportFormat }
              </h2>
             <div class="im-export-formats" data-toggle="buttons-radio">
             </div>
           </div>
           <div class="tab-pane im-export-columns">
               <button class="im-reset-cols btn disabled pull-right">
                 <i class="#{ intermine.icons.Undo }"></i>
                 #{ intermine.messages.actions.ResetColumns }
               </button>
              <h2>
                #{ intermine.messages.actions.WhichColumns }
              </h2>
              <div class="im-col-options">
                <div class="well">
                  <ul class="im-cols im-exported-cols nav nav-tabs nav-stacked"></ul>
                </div>
                <h4>#{ intermine.messages.actions.PossibleColumns }</h4>
                <div class="im-can-be-exported-cols">
                </div>
                <div style="clear:both;"></div>
              </div>
              <div class="im-col-options-bio">
              </div>
           </div>
           <div class="tab-pane im-export-rows">
             <h2>
              #{ intermine.messages.actions.WhichRows }
             </h2>
              <div class="form-horizontal">
                <fieldset class="im-row-selection control-group">
                  <label class="control-label">
                    #{ intermine.messages.actions.FirstRow }
                    <input type="text" value="1"
                            class="disabled input-mini im-first-row im-range-limit">
                  </label>
                  <label class="control-label">
                    #{ intermine.messages.actions.LastRow }
                    <input type="text"
                            class="disabled input-mini im-last-row im-range-limit">
                  </label>
                  <div style="clear:both"></div>
                  <div class="slider im-row-range-slider"></div>
                </fieldset>
              </div>
           </div>
           <div class="tab-pane im-export-output">
              <h3>
                #{ intermine.messages.actions.CompressResults }
              </h3>
              <div class="span11 im-compression-opts radio btn-group pull-right"
                    data-toggle="buttons-radio">
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
              <div style="clear:both"></div>
              <div class="im-output-options">
              </div>
           </div>
           <div class="tab-pane im-export-destination">
          <ul class="im-export-destinations nav nav-pills">
            <li class="active">
              <a href="#" data-destination="download-file">
                <i class="icon-paper-clip im-copy"></i>
                #{ intermine.messages.actions.ExportLong }
              </a>
            </li>
            <li>
              <a href="#" data-destination="galaxy">
                #{ intermine.messages.actions.SendToGalaxy }
              </a>
            </li>
            <li>
              <a href="#" data-destination="genomespace" >
                #{ intermine.messages.actions.SendToGenomespace }
              </a>
            </li>
          </ul>
            <div class="row-fluid im-export-destination-options">

              <div class="im-download-file active">
                <div class="btn-group im-what-to-show">
                  <button class="im-results-uri btn active">
                    #{ intermine.messages.actions.ResultsPermaLinkText }:
                  </button>
                  <button class="im-query-xml btn">
                    #{ intermine.messages.actions.QueryXML }
                  </button>
                </div>
                <span class="im-copy">
                  <i class="icon icon-link"></i>
                  #{ intermine.messages.actions.Copy }
                </span>

                <div class="well im-perma-link-content active"></div>
                <div class="well im-query-xml"></div>

                <div class="alert alert-block im-private-query">
                  <button type="button" class="close" data-dismiss="alert">×</button>
                  <h4>nb:</h4>
                  #{ intermine.messages.actions.IsPrivateData }
                </div>

              </div>

              <div class="im-galaxy">
                <form class="im-galaxy form form-compact well">
                  <label>
                    #{ intermine.messages.actions.GalaxyURILabel }
                    <input class="im-galaxy-uri" 
                          type="text" value="#{ intermine.options.GalaxyMain }">
                  </label>
                  <label>
                    #{ intermine.messages.actions.SaveGalaxyURL }
                    <input type="checkbox" disabled checked class="im-galaxy-save-url">
                  </label>
                </form>
              </div>

              <div class="im-genomespace">
                <div class="well">
                  <button class="btn btn-primary btn-block im-send-to-genomespace">
                    #{ intermine.messages.actions.SendToGenomespace }
                  </button>
                </div>
              </div>

            </div>
           </div>
         </div>
       </div>
      
      </div> <!-- End item -->
      
      <div class="item">
        <iframe class="gs-frame" width="0" height="0" frameborder="0"
          id="im-to-gs-#{ new Date().getTime() }">
        </iframe>
      </div>

      </div> <!-- end inner -->
      </div> <!-- end carousel -->

    </div>

    <!--
    -->

    <div class="modal-footer">
      <a href="#" class="btn btn-primary im-download pull-right"
              title="#{ intermine.messages.actions.ExportHelp }">
        <i class="icon #{ intermine.icons.Export }"></i>
        #{ intermine.messages.actions.Export }
      </a>
      <button class="btn btn-cancel pull-left im-cancel">
        #{ intermine.messages.actions.Cancel }
      </button>
    </div>
  """

  scope 'intermine.snippets.actions', {DownloadDialogue}
