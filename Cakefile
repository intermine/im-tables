{exec, spawn} = require "child_process"
fs     = require 'fs'
Q      = require 'q'
{_}    = require 'underscore'
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

readP = Q.nfbind fs.readFile
read = (fn, enc = 'utf8') -> readP fn, enc
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

execP = (cmd) ->
  def = Q.defer()
  exec cmd, (err, stdout, stderr) ->
    if err
      def.reject(err)
    else
      def.resolve(stdout, stderr)
  def.promise

DEFAULT_ERR_HANDLER = (err) -> console.error err

promiserToNode = (promiser) -> (cb) ->
    done = promiser()
    cb ?= DEFAULT_ERR_HANDLER
    done.then( -> cont cb).done()

FULL_BUNDLE = 'bundle.js.template'
BUNDLE_NAME = 'js/imtables-bundled.js'
MINIMAL_BUNDLE = 'mini-bundle.js.template'
MINI_BUNDLE_NAME = 'js/imtables-mini-bundle.js'

bundle = (templateFileName, outFileName) -> promiserToNode ->
  
  console.log "Bundling..."
  bundP = read templateFileName

  jqp = read 'components/jquery/jquery.js'
  usp = read 'components/underscore/underscore.js'
  bbp = read 'components/backbone/backbone.js'
  bsp = read('components/bootstrap/docs/assets/js/bootstrap.js').then patchBootstrap
  jquip = Q.all( read f for f in jquiFiles ).then (contents) -> contents.join '\n\n'
  imjsp = read 'components/imjs/js/im.js'
  imtp = read 'js/imtables.js'

  wrap = (wrapper, data) -> _.template wrapper, data
  bundleUp = ([bundle, jq, _, bb, bs, ui, imjs, imt]) -> wrap bundle, {jq, _, bb, bs, ui, imjs, imt}
  writeOut = writer outFileName
  uglyOutName = outFileName.replace /js$/, 'min.js'
  uglify = -> execP "./node_modules/.bin/uglifyjs -o #{ uglyOutName } #{ outFileName }"

  Q.all([bundP, jqp, usp, bbp, bsp, jquip, imjsp, imtp]).then(bundleUp).then(writeOut).then(uglify)
    
task 'do:bundle', 'bundle deps into main package', bundle FULL_BUNDLE, BUNDLE_NAME

task 'do:mini-bundle', 'build the minimal viable bundle', bundle MINIMAL_BUNDLE, MINI_BUNDLE_NAME

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

task 'build:ugly', 'Uglify the main artifact', ugly = promiserToNode ->
  console.log "Uglifying.."
  execP './node_modules/.bin/uglifyjs -o js/imtables.min.js js/imtables.js'

task 'prefix-css', 'Build a prefixed css file', prefixulate = promiserToNode ->
  console.log "Prefixing css..."
  read(BOOTSTRAP_COMP, 'utf8').then(JSON.parse).get('version').then (v) ->
    writeOut =  writer "css/bootstrap-#{ v }-prefixed.css"
    read(BOOTSTRAP_CSS, 'utf8').then(prefix).then(writeOut)

patchBootstrap = (text) ->
    text.replace /attr\(['"]data-target['"]\)/g, """data('target')"""

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
  return Q('writing') if writing
  console.log "Building source file"
  writeOut = writer 'build/build.coffee'

  footer = 'end_of_definitions()'

  writing = true
  Q.all([Q.all(deepRead(n) for n in neededEarly), deepRead('src')])
    .then((nested) -> (_.flatten names for names in nested))
    .then(([priorities, rest]) -> _.union priorities, rest)
    .then((fileNames) -> Q.all( read(f, 'utf8') for f in fileNames ))
    .then((contents) -> "#{ header }\n\n#{ contents.join('\n\n') }\n\n#{ footer }")
    .then(writeOut)
    .then -> writing = false

makeDirectory = (name) -> () -> exists(name).fail (err) ->
    console.log "Making #{ name }"
    mkdir name

task 'mkdir:out', 'Make the output directory', promiserToNode (makeOut = makeDirectory 'js')

writingDeps = false

otherDeps = ['lib/js/jquery-ui-1.10.1.custom.js']
jquiFiles = [
  'components/jquery-ui/ui/jquery.ui.core.js',
  'components/jquery-ui/ui/jquery.ui.widget.js',
  'components/jquery-ui/ui/jquery.ui.mouse.js',
  'components/jquery-ui/ui/jquery.ui.draggable.js',
  'components/jquery-ui/ui/jquery.ui.droppable.js',
  'components/jquery-ui/ui/jquery.ui.position.js',
  'components/jquery-ui/ui/jquery.ui.selectable.js',
  'components/jquery-ui/ui/jquery.ui.slider.js',
  'components/jquery-ui/ui/jquery.ui.sortable.js'
]
deps = jquiFiles.concat [
  'components/bootstrap/docs/assets/js/bootstrap.js'
]


DEPS = 'build:deps'
DEPS_DESC = 'concatenate dependencies'

task DEPS, DEPS_DESC, builddeps = promiserToNode ->
  return Q('writing') if writingDeps

  console.log "Building deps"
  dirName = "components/bootstrap/docs/assets/js"
  writeOut = writer 'js/deps.js'
  writingDeps = true
  stop = -> writingDeps = false
  wanted = (name) ->
    /bootstrap-\w+\.js$/.test(name) and not /(scrollspy|collapse)/.test(name)

  makeOut()
    .then(-> Q.all( read(f, 'utf8') for f in deps))
    .then((fileContents) -> fileContents.map(patchBootstrap).join('\n\n'))
    .then(writeOut)
    .then(stop)
  # .then(-> deepRead dirName)
  # .then(_.flatten)
  # .then((maybes) -> maybes.filter wanted)
  # .then((found) -> _.union otherDeps, found)
  # .then((fileNames) -> Q.all( read(f, 'utf8') for f in fileNames))

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
                        exec 'notify-send "Recompiled im-tables"'

task 'build:bundle', 'build a bundle', buildBundle = (next) ->
  clean -> prebuild -> concat -> compile -> ugly -> bundle(FULL_BUNDLE, BUNDLE_NAME) ->
    console.log "Bundled at #{new Date()}"
    next?()

task 'mini:bundle', 'build a mini bundle', miniBundle = (next) ->
  clean -> prebuild -> concat -> compile -> ugly -> bundle(MINIMAL_BUNDLE, MINI_BUNDLE_NAME) ->
    console.log "Mini-Bundled at #{new Date()}"
    next?()

task 'build:all', 'produce all build files', -> buildBundle miniBundle

task 'watch', 'Watch production files and rebuild the application', watch = (cb) ->
    console.log "Watching for changes in ./src"
    listen = (name) -> fs.watchFile name, (curr, prev) ->
      if +curr.mtime isnt +prev.mtime
        console.log "Saw change in #{ name } - rebuilding..."
        invoke 'build:bundle'
    deepRead('src').then(_.flatten).invoke('map', listen).done()
    
# vim: set syntax=coffee sw=2 ts=2 foldmethod=indent cc=100
