async = require 'async'
{program, client, delay, handleError, runJsFile, runJs, exit} = require './common'
PreviousStatementsDownloader = require './previous-statements-downloader'

# For if you're using the REPL
myRepl = null
echoDone = (err, result) ->
  myRepl.context.lastError = err
  myRepl.context.lastResult = result
  if err
    outputError(err)
  else
    console.log "Done, result is in `lastResult` variable."

repl = ->
  options =
    prompt: "HSBCScrape REPL> "
    useGlobal: true
    ignoreUndefined: true
  # Vanilla JS REPL:
  myRepl = require('repl').start options
  # Export useful things
  myRepl.context[key] = value for key, value of {client, delay, program, echoDone, runJs, runJsFile}
  myRepl.on 'exit', ->
    mainMenu()

mainMenu = ->
  accountList = null
  chosenAccount = null
  async.series
    loadMyAccountsPage: (next) ->
      console.log "Loading my accounts..."
      client.url  "https://www.hsbc.co.uk/1/3/personal/internet-banking", next
    getListOfAccounts: (next) ->
      console.log "Parsing list of accounts"
      runJsFile "accountlist", (err, list) ->
        if err
          console.error err
          return next err
        console.log list
        accountList = list
        next()
    chooseAccount: (next) ->
      console.log "Which account would you like to look at?"
      options = ("#{account.name} (#{account.details})" for account in accountList)
      program.choose options, (i) ->
        process.stdin.pause()
        chosenAccount = accountList[i]
        next()
    openAccount: (next) ->
      javascript = "document.getElementById(#{JSON.stringify(chosenAccount.formId)}).submit();"
      runJs javascript, (err) ->
        return next err if err?
        next()
    waitABit: (next) ->
      delay 3000, next
    downloadAllPreviousStatements: (next) ->
      downloader = new PreviousStatementsDownloader()
      downloader.downloadAll next
  , (err) ->
    return handleError err if err

    console.log "What would you like to do now?"
    options = [
      'REPL'
      'exit'
    ]
    program.choose options, (i) ->
      process.stdin.pause()
      switch options[i]
        when 'REPL'
          console.log "Switching to #{"REPL".bold} mode..."
          repl()
        else
          console.log "Exiting..."

login = ->
  async.series
    goToHSBC: (next) ->
      client.url "https://www.hsbc.co.uk/1/2/", next
    clickLogOn: (next) ->
      client.click "#onlineBanking a.redBtn", next
    getId: (next) ->
      return next() if program.bankingId
      program.prompt 'Internet Banking ID: ', (text) ->
        program.bankingId = text
        process.stdin.pause()
        next()
    fillOutIBID: (next) ->
      client.setValue "#intbankingID", program.bankingId, next
    submitLogonForm: (next) ->
      client.submitForm "#logonForm", next
    getPassword: (next) ->
      return next() if program.bankingPassword
      program.prompt 'Password: ', (text) ->
        program.bankingPassword = text
        process.stdin.pause()
        next()
    fillOutPassword: (next) ->
      client.setValue "#passwd", program.bankingPassword, next
    getSecurityCode: (next) ->
      program.prompt 'Security code (from dongle): ', (text) ->
        program.securityCode = text
        process.stdin.pause()
        next()
    fillOutSecurityCode: (next) ->
      client.setValue "#secNumberInput", program.securityCode, next
    submitPasswordForm: (next) ->
      client.submitForm "form.login-form-two", next
    waitABit: (next) ->
      delay 3000, next
    checkSuccess: (next) ->
      client.isVisible "#jsShowAccounts", (err, visible) ->
        return next(err) if err?
        return next() if visible
        return next new Error("Login failed.")
  , (err) ->
    return handleError err if err?
    console.log "#{"Login successful".green}: transitioning to main menu."
    mainMenu()

console.log "Welcome to HSBC Scrape".green
login()
