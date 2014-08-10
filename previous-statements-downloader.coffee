async = require 'async'
fs = require 'fs'
{program, client, delay, handleError, runJsFile, runJs, exit} = require './common'

# WARNING: saving/loading in this file is *synchronous*.

class PreviousStatementsDownloader
  constructor: (@filename) ->

  restore: ->
    console.log "Restoring progress..."
    try
      jsonData = fs.readFileSync @filename, 'utf8'
      @statements = JSON.parse jsonData
    @statements ?= {}
    console.log "... done"
    return

  save: ->
    fs.writeFileSync @filename, JSON.stringify(@statements, null, 2)
    return

  downloadAll: (callback) ->
    @callback = callback
    @restore()
    client.url "https://www.hsbc.co.uk/1/3/personal/internet-banking/previous-statements", (err) =>
      return handleError err if err?
      @processVisibleStatements()
    return

  processVisibleStatements: ->
    runJsFile 'statementlist', (err, list) =>
      return handleError err if err?
      #list.accountName / accountNumber / statements / nextSet
      #statement.href / title

      # Find incomplete statements
      for statement in list.statements
        console.log "    Analysing #{statement.title}"
        if !@statements[statement.title]?.complete
          console.log "      -> Incomplete!"
          return @loadStatement statement
      # Must have completed the page!
      if list.nextSet?
        console.log "Navigating to next set of statements..."
        return client.url list.nextSet, (err) =>
          return handleError err if err?
          @processVisibleStatements()
      # Must have completed everything!
      console.log "Have downloaded all statements!"
      return @callback()
      return
    return

  loadStatement: (statement) ->
    console.log "Processing statement '#{statement.title}'..."
    client.url statement.href, (err) =>
      return handleError err if err?
      @parseStatement(statement)
    return

  parseStatement: (statement) ->
    runJsFile 'statement', (err, details) =>
      #details.accountName / accountNumber / back / openingBalance / closingBalance / date / rows
      #row.date / type / description / in / out / balance / href
      if !@statements[statement.title]?
        @statements[statement.title] = details
        @save()

      existingDetails = @statements[statement.title]
      # Make sure we're on the same page
      fields = ['accountName', 'accountNumber', 'openingBalance', 'closingBalance', 'date']
      for field in fields
        if existingDetails[field] isnt details[field]
          return handleError new Error "These statements don't match! Field '#{field}', '#{existingDetails[field]}' != '#{details[field]}'"

      # Update the hrefs (since they probably change)
      for row, i in details.rows when row.href?
        existingDetails.rows[i].href = row.href
      existingDetails.back = details.back

      details = null # Don't use this any more!

      # Process any unfetched extra details
      for row, i in existingDetails.rows when row.href? and !row.details?
        return @getTransactionDetails statement, row

      # We must be complete!
      existingDetails.complete = true
      @save()

      # Return to statement list
      client.url existingDetails.back, (err) =>
        return handleError err if err?
        @processVisibleStatements()
      return
    return

  getTransactionDetails: (statement, row) ->
    details = null
    async.series
      browseToDetailsScreen: (next) ->
        client.url row.href, next

      parseThePage: (next) ->
        runJsFile 'extradetails', (err, fetchedDetails) ->
          return next err if err?
          details = fetchedDetails
          row.details = details.description
          console.log "Got details for transaction '#{row.description}': #{row.details.replace(/\n/g, " | ")}"
          next()

      goBackToStatement: (next) ->
        client.url details.back, next

    , (err) =>
      return handleError err if err?
      @save()
      @parseStatement(statement)
    return

module.exports = PreviousStatementsDownloader
