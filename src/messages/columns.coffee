#FIXME - add these to messages
scope 'intermine.messages.columns', {
    FindColumnToAdd: 'Add a new Column',
    OrderVerb: 'Add / Remove / Re-Arrange',
    OrderTitle: 'Columns',
    SortVerb: 'Configure',
    SortTitle: 'Sort-Order',
    OnlyColsInView: 'Only show columns in the table:',
    SortingHelpTitle: 'What Columns Can I Sort by?',
    SortingHelpContent: """
      A table can be sorted by any of the attributes of the objects
      which are in the output columns or constrained by a filter, so
      long as they haven't been declared to be optional parts of the
      query. So if you are displaying <span class="label path">Gene > Name</span>
      and <span class="label path">Gene > Exons > Symbol</span>, and also
      <span class="label path">Gene > Proteins > Name</span> if the gene
      has any proteins (ie. the proteins part of the query is optional), then
      you can sort by any of the attributes attached to
      <span class="label path available">Gene</span>
      or <span class="label path available">Gene > Exons</span>,
      whether or not you have selected them for output, but you could not sort by
      any of the attributes of <span class="label path available">Gene > Proteins</span>,
      since these items may not be present in the results.
    """
}

