"use strict"

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
    [ 'department.name', '=', 'Sales' ]
  ]

main = -> summarise query, 'department.name'

$ main
