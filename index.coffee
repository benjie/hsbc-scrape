require 'colors'
async = require 'async'
webdriverjs = require 'webdriverjs'
program = require 'commander'

program.version require('./package.json').version
program.option '-I, --banking-id <ID>', 'Internet banking ID'
program.option '-p, --banking-password <password>', 'Internet banking password'
program.parse process.argv

console.log "Welcome to HSBC Scrape".green

options = {
  logLevel: 'silent'
}
client = webdriverjs.remote(options)
client.init()

async.series
  goToHSBC: (next) ->
    client.url "https://www.hsbc.co.uk/1/2/", next
  clickLogOn: (next) ->
    client.click "#onlineBanking a.redBtn", next
  getId: (next) ->
    return next() if program.bankingId
    program.prompt 'Internet Banking ID: ', (text) ->
      program.bankingId = text
      next()
  fillOutIBID: (next) ->
    client.setValue "#intbankingID", program.bankingId, next
  submitLogonForm: (next) ->
    client.submitForm "#logonForm", next
  getPassword: (next) ->
    return next() if program.bankingPassword
    program.prompt 'Password: ', (text) ->
      program.bankingPassword = text
      next()
  fillOutPassword: (next) ->
    client.setValue "#passwd", program.bankingPassword, next
  getSecurityCode: (next) ->
    program.prompt 'Security code (from dongle): ', (text) ->
      program.securityCode = text
      next()
  fillOutSecurityCode: (next) ->
    client.setValue "#secNumberInput", program.securityCode, next
  submitPasswordForm: (next) ->
    client.submitForm "form.login-form-two", next
  checkSuccess: (next) ->
    client.isVisible "#jsShowAccounts", (err, visible) ->
      return next(err) if err?
      return next() if visible
      return next new Error("Login failed.")
  freeze: (next) ->
    # This deliberately doesn't call next coz I want it to sit here forever
, (err) ->
  if err?
    console.error "#{"ERROR: ".bold}#{err.message}".red
    console.error err.stack
  client.end()
