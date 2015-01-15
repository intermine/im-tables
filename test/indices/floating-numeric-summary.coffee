"use strict"

$ = require "jquery"
summarise = require '../lib/summary'

query =
  select: [
    "owedBy.name"
    "debt"
    "interestRate"
  ]
  from: "Broke"

main = -> summarise query, 'interestRate'

$ main
