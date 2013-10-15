fs = require 'fs'

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

statements = []
for name, statement of json
  statement.date = new Date(Date.parse(statement.date))
  statements.push statement

statements.sort (a, b) -> a.date - b.date

qif = "!Type:Bank\n"
for statement in statements
  for row in statement.rows
    #console.log "+ #{row.in} - #{row.out} = #{row.balance}"
    desc = row.details ? row.description
    desc = desc.replace /\n/g, " | "
    date = new Date(Date.parse("#{row.date} #{statement.date.getFullYear()}"))
    if +date > +statement.date + 1000 * 60 * 60 * 24 * 31
      date.setFullYear(date.getFullYear()-1)
    qif += "D#{date.toISOString().substr(0,10)}\n"
    qif += "T#{(row.in - row.out)/100}\n"
    qif += "P#{desc}\n"
    qif += "^\n"

fs.writeFileSync "#{jsonFile.replace(/.json$/, "")}.qif", qif
