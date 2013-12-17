{getMessage} = require '../messages'
icons = require '../icons'

module.exports = -> """

  <div class="modal-header">
    <a  class="close im-closer" data-dismiss="modal">close</a>
    <h2>
      #{ getMessage("actions.ExportTitle") }
    </h2>
  </div>

  <div class="modal-body tab-content">
    <div class="active item">

      <div class="tabbable tabs-left">
        <ul class="nav nav-tabs">
          <li class="active">
            <a  class="im-export-format">format</a>
          </li>
          <li>
            <a  class="im-export-columns">columns</a>
          </li>
          <li>
            <a  class="im-export-rows">Rows</a>
          </li>
          <li>
            <a  class="im-export-output">Output</a>
          </li>
          <li>
            <a  class="im-export-destination">
            Destination: <span class="im-current"></span>
            </a>
          </li>
          <div class="alert alert-info">
            <p>
            <i class="icon-info-sign"></i>
            #{ getMessage("actions.ConfigureExportHelp") }
            </p>
          </div>
        </ul>
        <div class="tab-content">
          <div class="tab-pane active im-export-format">
            <h2>
              #{ getMessage("actions.ExportFormat") }
            </h2>
            <div class="im-export-formats" data-toggle="buttons-radio">
            </div>
          </div>
          <div class="tab-pane im-export-columns">
              <button class="im-reset-cols btn disabled pull-right">
                <i class="#{ icons.Undo }"></i>
                #{ getMessage("actions.ResetColumns") }
              </button>
            <h2>
              #{ getMessage("actions.WhichColumns") }
            </h2>
            <div class="im-col-options">
              <div class="well">
                <ul class="im-cols im-exported-cols nav nav-tabs nav-stacked"></ul>
              </div>
              <h4>#{ getMessage("actions.PossibleColumns") }</h4>
              <div class="im-can-be-exported-cols">
              </div>
              <div style="clear:both;"></div>
            </div>
            <div class="im-col-options-bio">
            </div>
          </div>
          <div class="tab-pane im-export-rows">
            <h2>
            #{ getMessage("actions.WhichRows") }
            </h2>
            <div class="form-horizontal">
              <fieldset class="im-row-selection control-group">
                <label class="control-label">
                  #{ getMessage("actions.FirstRow") }
                  <input type="text" value="1"
                          class="disabled input-mini im-first-row im-range-limit">
                </label>
                <label class="control-label">
                  #{ getMessage("actions.LastRow") }
                  <input type="text"
                          class="disabled input-mini im-last-row im-range-limit">
                </label>
                <div style="clear:both"></div>
                <div class="slider im-row-range-slider"></div>
              </fieldset>
            </div>
          </div>
          <div class="tab-pane im-export-output">
            <label>
              #{ getMessage("actions.CompressResults") }
            </label>
            <div class="span11 im-compression-opts radio btn-group pull-right"
                  data-toggle="buttons-radio">
              <button class="btn active im-no-compression span7">
                #{ getMessage("actions.NoCompression") }
              </button>
              <button class="btn im-gzip-compression span2">
                #{ getMessage("actions.GZIPCompression") }
              </button>
              <button class="btn im-zip-compression span2">
                #{ getMessage("actions.ZIPCompression") }
              </button>
            </div>
            <div style="clear:both"></div>
            <div class="im-output-options">
            </div>
          </div>
          <div class="tab-pane im-export-destination">
        <ul class="im-export-destinations nav nav-pills">
          <li class="active">
            <a  data-destination="download-file">
              <i class="#{ icons.Download }"></i>
              #{ getMessage("actions.ExportLong") }
            </a>
          </li>
        </ul>
          <div class="row-fluid im-export-destination-options">

            <div class="im-download-file active">
              <div class="btn-group im-what-to-show">
                <button class="im-results-uri btn active">
                  #{ getMessage("actions.ResultsPermaLinkText") }:
                </button>
                <button class="im-query-xml btn">
                  #{ getMessage("actions.QueryXML") }
                </button>
              </div>
              <span class="im-copy">
                <i class="icon #{ icons.ClipBoard }"></i>
                #{ getMessage("actions.Copy") }
              </span>

              <div class="well im-perma-link-content active"></div>
              <div class="well im-query-xml"></div>

              <div class="alert alert-block im-private-query">
                <button type="button" class="close im-closer" data-dismiss="alert">×</button>
                <h4>nb:</h4>
                #{ getMessage("actions.IsPrivateData") }
              </div>

              <div class="alert alert-block alert-info im-long-uri">
                <button type="button" class="close im-closer" data-dismiss="alert">×</button>
                <h4>nb:</h4>
                #{ getMessage("actions.LongURI") }
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
  </div>

  <!--
  -->

  <div class="modal-footer">
    <a  class="btn btn-primary im-download pull-right">
      <i class="icon #{ icons.Export }"></i>
      #{ getMessage("actions.Export") }
    </a>
    <button class="btn btn-cancel pull-left im-cancel">
      #{ getMessage("actions.Cancel") }
    </button>
  </div>
"""
