{exec} = require "child_process"
fs     = require 'fs'
Q      = require 'q'
_      = require 'underscore'
IM     = require './package.json'

BLACKLIST = [
  'html', 'body', '.modal', '.modal-backdrop', '.modal-header', '.modal-footer',
  '.modal-body', '.modal-form', '.tooltip', '.tooltip-inner', '.popover', '.popover-title'
]

prefix = require('prefix-css-node')#.prefixer '.bootstrap', BLACKLIST

header = """
  ###
   * InterMine Results Tables Library v#{IM.version}
   * web: #{ IM.homepage }
   * repo: #{ IM.repository.url }
   *
   * Copyright 2012, 2013, #{ IM.author.name } and InterMine
   * Released under the #{ IM.license } license.
   * 
   * Built at #{new Date()}
  ###
"""

BOOTSTRAP_CSS = "components/bootstrap/docs/assets/css/bootstrap.css"
BOOTSTRAP_COMP = "components/bootstrap/component.json"

read = Q.nfbind fs.readFile
write = Q.nfbind fs.writeFile
readdir = Q.nfbind fs.readdir
mkdir = Q.nfbind fs.mkdir
exists = (path) ->
  def = Q.defer()
  fs.exists path, (itDoes) ->
    if itDoes
      def.resolve(true)
    else
      def.reject(false)
  def.promise

writer = (fname) -> (data, enc = 'utf8') -> write fname, data, enc

deepRead = (name) ->
  if fs.statSync(name).isDirectory()
    readdir(name).then (files) -> Q.all( deepRead "#{ name }/#{ f }" for f in files )
  else
    Q name

cont = (cb) -> cb() if typeof cb is 'function'

DEFAULT_ERR_HANDLER = (err) -> console.error err

promiserToNode = (promiser) -> (cb) ->
    done = promiser()
    cb ?= DEFAULT_ERR_HANDLER
    done.then( -> cont cb).done()

task 'copyright', 'Show the copyright header', ->
    console.log header

task 'build:compile', 'Build project from build/* to js/imtables.js', compile = (cb) ->
    console.log "Compiling #{IM.name} (#{IM.version}) to /js"
    exec 'coffee --compile --join js/imtables.js build/', (err, stdout, stderr) ->
        if err
            console.log "Compilation failed:", stdout + stderr
            exec "notify-send 'Compilation Failed' '#{ err + stdout + stderr }'", cb
        else
            cont cb

task 'prefix-css', 'Build a prefixed css file', prefixulate = promiserToNode ->
  console.log "Prefixing css..."
  read(BOOTSTRAP_COMP, 'utf8').then(JSON.parse).get('version').then (v) ->
    writeOut =  writer "css/bootstrap-#{ v }-prefixed.css"
    read(BOOTSTRAP_CSS, 'utf8').then(prefix).then(writeOut)

task 'wrap:bb', promiserToNode ->
  readingBB = read 'components/backbone/backbone.js', 'utf8'
  readingUS = read 'components/underscore/underscore.js', 'utf8'
  readingWrapper = read 'lib/backbone-wrapper.js', 'utf8'

  Q.all([readingUS, readingBB, readingWrapper]).then ([us, bb, wrapper]) ->
    [left, right] = wrapper.split 'LIBRARIES'
    wrapped = left + us + "\n\n" + bb + right
    write 'lib/backbone-wrapped.js', wrapped, 'utf8'

writing = false

neededEarly = [
  "src/shiv.coffee",
  "src/module.coffee",
  "src/utils.coffee",
  "src/options.coffee",
  "src/icons.coffee",
  "src/messages",
  "src/constraintadder.coffee"
]

CONCAT_DESC = 'Concatenate source files to a single application script'
CONCAT = 'build:concat'

task CONCAT, CONCAT_DESC, concat = promiserToNode ->
  return Q.reject('writing') if writing
  console.log "Building source file"
  writeOut = writer 'build/build.coffee'

  writing = true
  Q.all([Q.all(deepRead(n) for n in neededEarly), deepRead('src')])
    .then((nested) -> (_.flatten names for names in nested))
    .then(([priorities, rest]) -> _.union priorities, rest)
    .then((fileNames) -> Q.all( read(f, 'utf8') for f in fileNames ))
    .then((contents) -> "#{ header }\n\n#{ contents.join('\n\n') }")
    .then(writeOut)
    .then -> writing = false

makeDirectory = (name) -> () -> exists(name).fail (err) ->
    console.log "Making #{ name }"
    mkdir name

task 'mkdir:out', 'Make the output directory', promiserToNode (makeOut = makeDirectory 'js')

writingDeps = false

otherDeps = ['lib/js/jquery-ui-1.10.1.custom.js']

DEPS = 'build:deps'
DEPS_DESC = 'concatenate dependencies'

task DEPS, DEPS_DESC, builddeps = promiserToNode ->
  return Q.reject('writing') if writingDeps

  console.log "Building deps"
  dirName = "components/bootstrap/docs/assets/js"
  writeOut = writer 'js/deps.js'
  writingDeps = true
  stop = -> writingDeps = false

  makeOut()
    .then(-> deepRead dirName)
    .then((found) -> otherDeps.concat _.flatten found)
    .then((fileNames) -> Q.all( read(f, 'utf8') for f in fileNames))
    .then((fileContents) -> fileContents.join('\n\n'))
    .then(writeOut)
    .then(stop)

cleaning = false

task 'clean:js', 'Remove old js', cleanjs = (cb) ->
    jsf = "js/imtables.js"
    fs.stat jsf, (err, stats) ->
        if stats? and not cleaning
            cleaning = true
            console.log "Removing old compiled js"
            fs.unlink jsf, (err) ->
                cleaning = false
                throw err if err
                cont cb
        else
            cont cb

task 'clean:build', 'Remove old build', cleanbuild = (cb) ->
    buildf = "build/build.coffee"
    fs.stat buildf, (err, stats) ->
        if stats? and not cleaning
            cleaning = true
            console.log "Removing old build"
            fs.unlink buildf, (err) ->
                cleaning = false
                throw err if err
                cont cb
        else
            cont cb

task 'clean', "Remove old artifacts", clean = (cb) ->
    cleanbuild ->
        cleanjs ->
            console.log "Cleaned up"
            cont cb

task 'build:setup', 'Set things up for building', prebuild = (cb) ->
    console.log "Checking for build directory"
    fs.stat "build", (err, stats) ->
        if stats?
            cont cb
        else
            fs.mkdir "build", "770", ->
                cont cb

task 'build', 'Run a complete build', ->
    clean ->
        prebuild ->
            builddeps ->
                concat ->
                    compile ->
                        console.log "done at #{new Date()}"

task 'watch', 'Watch production files and rebuild the application', watch = (cb) ->
    console.log "Watching for changes in ./src"
    fs.readdir 'src', (err, files) ->
        throw err if err
        for f in files then do (f) ->
            fs.watchFile "src/#{f}", (curr, prev) ->
                if +curr.mtime isnt +prev.mtime
                    console.log "Saw change in js/#{f} - rebuilding"
                    invoke 'build'
    
# vim: set syntax=coffee sw=2 ts=2 foldmethod=indent cc=100
