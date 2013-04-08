scope 'intermine.export.snippets',
  Galaxy: -> """
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
    """
  Genomespace: -> """
    <div class="im-genomespace">
      <div class="well">
        <label>File Name</label>
        <div class="input-append">
          <input class="im-genomespace-filename input" style="width: 40em" type="text">
          <span class="add-on im-format"></span>
        </div>
      </div>
    </div>
    """
