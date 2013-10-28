fs = require 'fs'
try
  categorizer = require './categorizer'

jsonFile = process.argv[2]

if !jsonFile?
  console.error "No JSON file specified"
  process.exit 1

if !jsonFile.match /\.json$/
  console.error "JSON file must end in .json"
  process.exit 2

try
  json = JSON.parse fs.readFileSync(jsonFile)
catch e
  console.error "Could not decode JSON"
  process.exit 3

# Delete empty statements
for name, statement of json
  if statement.rows.length is 0
    delete json[name]

# Fix all the dates.
statements = []
for name, statement of json
  statement.date = new Date(Date.parse(statement.date)+1000*60*60*12)
  for row in statement.rows
    date = new Date(Date.parse("#{row.date} #{statement.date.getFullYear()}")+1000*60*60*12)
    if +date > +statement.date + 1000 * 60 * 60 * 24 * 31
      date.setFullYear(date.getFullYear()-1)
    row.date = date
  statements.push statement

statements.sort (a, b) -> a.date - b.date

qif = "!Account\n"
name = statements[0].accountName.replace(/\s+,/g, ",").replace(/\s+/g, " ")
qif += "N#{name}\n"
qif += "TBank\n"
qif += "^\n"
qif += "!Type:Bank\n"

date = statements[0].rows[0].date
qif += "D#{date.toISOString().substr(0,10)}"
qif += "POpening Balance\n"
qif += "T#{statements[0].openingBalance/100}\n"
qif += "CR\n"
qif += "^\n"
for statement in statements
  for row in statement.rows
    #console.log "+ #{row.in} - #{row.out} = #{row.balance}"
    notes = row.details ? ""
    notes = notes.replace row.description, ""
    notes = notes.replace /(^\s+|\s+$)/g, ""
    notes = notes.replace /\n/g, " | "
    notes = notes.replace /\s+/g, " "
    row.notes = notes
    qif += "D#{row.date.toISOString().substr(0,10)}\n"
    qif += "T#{(row.in - row.out)/100}\n"
    qif += "P#{row.description}\n"
    qif += "M#{row.notes}\n"
    category = categorizer?.categorize(row)
    if category
      qif += "L#{category}\n"
    qif += "CR\n"
    qif += "^\n"

fs.writeFileSync "#{jsonFile.replace(/.json$/, "")}.qif", qif
