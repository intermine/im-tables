fs = require 'fs'
_ = require 'underscore'

select_html = fs.readFileSync __dirname + '/select.html', 'utf8'
select_templ = _.template select_html, variable: 'data'

exports.select = (options, selectedTest = (-> false), classes = '', contentHandler = null) ->
  select_templ {options, selectedTest, classes, contentHandler}

