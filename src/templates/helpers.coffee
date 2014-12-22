fs = require 'fs'
_ = require 'underscore'
Options = require '../options'

select_html = fs.readFileSync __dirname + '/select.html', 'utf8'
select_templ = _.template select_html, variable: 'data'

exports.select = (options,
  selectedTest = (-> false),
  classes = '',
  contentHandler = null,
  key = ((x) -> x?.value)) ->
  select_templ {options, selectedTest, classes, contentHandler, key}

exports.numToString = (number) ->
  sep = Options.get 'NUM_SEPARATOR'
  every = Options.get 'NUM_CHUNK_SIZE'
  rets = []
  i = 0
  chars =  (number + "").split("")
  len = chars.length
  groups = _(chars).groupBy (c, i) ->
    Math.floor((len - (i + 1)) / every).toFixed()
  while groups[i]
    rets.unshift groups[i].join("")
    i++
  return rets.join(sep)
