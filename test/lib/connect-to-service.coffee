imjs = require "imjs"

host = process.env.MINE_HOST or global.location.hostname
port = process.env.MINE_PORT or '8080'
token = 'test-user-token'
TESTMODEL   = "http://#{ host }:#{ port }/intermine-demo"
BIOTESTMINE = "http://#{ host }:#{ port }/biotestmine"

conn = imjs.Service.connect root: TESTMODEL

# An unauthenticated demo connection.
exports.connection = conn

# An authenticated demo connection
exports.authenticatedConnection = conn.connectAs token

# An unauthenticated connection to a genomic mine.
exports.genomic = imjs.Service.connect root: BIOTESTMINE

