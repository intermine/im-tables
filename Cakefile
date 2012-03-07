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

cont = (cb) ->
    cb() if typeof cb is 'function'

task 'copyright', 'Show the copyright header', ->
    console.log header

task 'build:compile', 'Build project from src/*.coffee to lib/*.js', compile = (cb) ->
    console.log "Compiling #{IM.NAME} (#{IM.VERSION}) to /js"
    exec 'coffee --compile --output js/ src/', (err, stdout, stderr) ->
        throw err if err
        cont cb

writing = false

task 'build:concat',
    'Concatenate the resulting .js files to a single application script',
    concat = (cb) ->
        console.log "Reading js"
        unless writing
            writing = true
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
                writing = false
                throw err if err
                cont cb

cleaning = false

task 'clean', 'Remove old build', clean = (cb) ->
    buildf = "js/imtables.js"
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


task 'build', 'Run a complete build', ->
    clean ->
        compile ->
            concat ->
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
    

# vim: set syntax=coffee
