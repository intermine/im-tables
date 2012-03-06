{exec} = require "child_process"
fs     = require 'fs'
{IM}     = require './intermine.spec'

header = """
  /**
   * InterMine Results Tables Library v#{IM.VERSION}
   * http://www.intermine.org
   *
   * Copyright 2012, Alex Kalderimis
   * Released under the LGPL license.
   */

"""

task 'copyright', 'Show the copyright header', ->
    console.log header

task 'build:compile', 'Build project from src/*.coffee to lib/*.js', compile = (cb) ->
    console.log "Compiling #{IM.NAME} (#{IM.VERSION}) to /js"
    exec 'coffee --compile --output js/ src/', (err, stdout, stderr) ->
        throw err if err
        cb() if typeof cb is 'function'

task 'build:concat', 'Concatenate the resulting .js files to a single application script', concat = (cb) ->
    console.log "Reading js"
    fs.readdir 'js', (err, files) ->
        appContents = new Array remaining = files.length
        throw err if err
        for f, i in files then do (f, i) ->
            fs.readFile "js/#{f}", 'utf8', (err, fileContents) ->
                appContents[i] = fileContents
                process(appContents) if --remaining is 0
    process = (texts) ->
        console.log "Writing build"
        fs.writeFile 'js/imtables.js', header + texts.join('\n\n'), 'utf8', (err) ->
            throw err if err
            cb() if typeof cb is 'function'

task 'clean', 'Remove old build', clean = (cb) ->
    console.log "Removing old build"
    fs.unlink 'js/imtables.js', (err) ->
        throw err if err
        cb() if typeof cb is 'function'

task 'build', 'Run a complete build', ->
    compile ->
        concat ->
            console.log "done"

task 'watch', 'Watch production files and rebuild the application', watch = (cb) ->
    console.log "Watching for changes in ./src"
    fs.readdir 'src', (err, files) ->
        throw err if err
        for f in files then do (f) ->
            fs.watchFile "src/#{f}", (curr, prev) ->
                if +curr.mtime isnt +prev.mtime
                    console.log "Saw change in js/#{f} - rebuilding"
                    invoke 'build'
    

# vim: set syntax=coffee
