"use strict"

###
# This is daft really - in the real world this should never
# happen because the table would not offer summaries for
# columns if it itself is empty. Still, everything must be
# tested.
###

$ = require "jquery"
summarise = require '../lib/summary'

query =
  name: "older than 35"
  select: [
    "name"
    "age"
    "department.name"
    "department.company.name"
  ]
  from: "Employee"
  where: [
    [ "age", "=", 1000000 ]
  ]

main = -> summarise query, 'name'

$ main
