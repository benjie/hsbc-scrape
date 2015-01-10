fs = require 'fs'
require 'colors'
webdriverjs = require 'webdriverjs'
program = require 'commander'

program.version require('./package.json').version
program.option '-I, --banking-id <ID>', 'Internet banking ID'
program.option '-p, --banking-password <password>', 'Internet banking password'
program.parse process.argv

delay = (ms, cb) -> setTimeout cb, ms

options = {
  logLevel: 'silent'
}
client = webdriverjs.remote(options)
client.init()

outputError = (err) ->
  console.error "#{"ERROR: ".bold}#{err.message}".red
  console.error err.stack

handleError = (err) ->
  outputError(err)
  delay 10000, ->
    exit()

runJsFile = (filename, callback) ->
  javascript = fs.readFileSync("#{filename}.js").toString('utf8')
  attempts = 0
  doIt = ->
    attempts++
    runJs javascript, (e) ->
      if e and attempts < 3
        console.error("Running JS failed; trying again (#{attempts+1}/3)")
        setTimeout(doIt, attempts * attempts * 250)
      else
        callback.apply this, arguments
  doIt()

runJs = (javascript, callback) ->
  client.execute javascript, [], (err, res) ->
    return callback err if err?
    return callback null, res.value

exit = ->
  client.end()
  console.log "Node #{"should".bold} exit very soon... But it mightn't, so Control-C is your backup plan."

module.exports = {program, client, delay, handleError, runJsFile, runJs, exit}
