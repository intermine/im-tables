"use strict"

$ = require "jquery"
summarise = require '../lib/summary'

query =
  name: "older than 35"
  select: [
    "name"
    "manager.name"
    "employees.name"
    "employees.age"
  ]
  from: "Department"
  where: [
    [ "employees.age", ">", 35 ]
  ]


main = -> summarise query, 'employees.age'

$ main
