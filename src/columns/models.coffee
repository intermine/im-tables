do ->

  class PossibleColumns extends Backbone.Collection

    initialize: (_, {@exported}) ->
      @on 'close', => @each (m) -> m.destroy()

  scope 'intermine.columns.models', {PossibleColumns}

