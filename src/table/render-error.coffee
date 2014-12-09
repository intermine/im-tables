define 'table/render-error', ->

  errorTempl = _.template """
    <div class="alert alert-error">
      <h2>Oops!</h2>
      <p><i><%- error %></i></p>
      <p><%= body %></p>
      <a class="btn btn-primary pull-right"
         href="mailto://<%- mailto %>">Email the help desk</a>
      <button class="btn btn-error">Show query</button>
      <p class="query-xml" style="display:none" class="well">
        <textarea><%= query %></textarea>
      <p>
    </div>
  """

  return (query, err, time) ->
    time ?= new Date()
    console.error(err, err?.stack)
    if /(Type|Reference)Error/.test(String(err))
      errConf = intermine.options.ClientApplicationError
      message = errConf.Heading
    else
      errConf = intermine.options.ServerApplicationError
      message = (err?.message ? errConf.Heading)

    mailto = query.service.help + "?" + $.param {
        subject: "Error running embedded table query"
        body: """
            We encountered an error running a query from an
            embedded result table.
            
            page:       #{ window.location }
            service:    #{ query.service.root }
            error:      #{ err }
            date-stamp: #{ time }

            -------------------------------
            IMJS:       #{ intermine.imjs.VERSION }
            -------------------------------
            IMTABLES:   #{ intermine.imtables.VERSION }
            -------------------------------
            QUERY:      #{ query.toXML() }
            -------------------------------
            STACK:      #{ err?.stack }
        """
    }, true
    # stupid jquery 'wontfix' indeed. grumble
    mailto = mailto.replace(/\+/g, '%20')

    notice = $ errorTempl
      error: message
      body: errConf.Body
      query: query.toXML()
      mailto: mailto

    notice.find('button').click -> notice.find('.query-xml').slideToggle()

    return notice
