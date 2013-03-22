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
        <button class="btn btn-primary btn-block im-send-to-genomespace">
          #{ intermine.messages.actions.SendToGenomespace }
        </button>
      </div>
    </div>
    """
