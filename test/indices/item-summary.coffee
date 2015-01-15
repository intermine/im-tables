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
    [ "age", ">", 35 ]
  ]

main = -> summarise query, 'department.name'

$ main
