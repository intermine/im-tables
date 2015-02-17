imjs = require "imjs"

root = "http://#{ global.location.hostname }:8080/intermine-demo"
token = 'test-user-token'

conn = imjs.Service.connect(root: root)

exports.connection = conn

exports.authenticatedConnection = conn.connectAs token

