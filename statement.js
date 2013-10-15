function pennies(n) {
  n = parseFloat(n);
  if (isNaN(n)) {
    n = 0;
  }
  return Math.round(n * 100);
}

var result = {};
var $details = $(".extContentHighlightPib:first");
result.accountName = $.trim($details.find(".hsbcAccountName").text());
result.accountNumber = $.trim($details.find(".hsbcAccountNumber").text());

var $statement = $(".extContentHighlightPib:last");
result.date = $.trim($statement.find(".extPibRow:nth-of-type(1) .hsbcTextRight").text());
result.rows = [];

var $rows = $statement.find("table tbody tr");
var first = true;
var previousBalance = null;
$rows.each(function(){
  var $row = $(this);
  var row = {}
  var fields = ['date', 'type', 'description', 'out', 'in', 'balance', 'overdrawn'];
  for (var i = 0, l = fields.length; i < l; i++) {
    var field = fields[i];
    var $td = $row.find("td:nth-of-type("+(i+1)+")");
    row[field] = $.trim($td.text());
    if (field == 'description') {
      var $link = $td.find("a");
      if ($link.length) {
        row.href = $link[0].href;
      }
    }
  }

  row.out = pennies(row.out);
  row.in = pennies(row.in);
  row.balance = pennies(row.balance);
  if (row.overdrawn == 'D') {
    row.balance = -row.balance;
  }

  if (row.type == '') {
    if (first === true) {
      result.openingBalance = row.balance;
      previousBalance = result.openingBalance;
      first = false;
    } else if (first === false) {
      result.closingBalance = row.balance;
    } else {
      throw new Error("Too many rows with no type?!");
    }
  } else {
    if (!row.balance) {
        row.balance = previousBalance + row.in - row.out;
    }
    if (row.balance != previousBalance + row.in - row.out) {
      throw new Error("Doesn't add up... Previous balance "+previousBalance + " + " + row.in + " - " + row.out + " != " + row.balance);
    }
    result.rows.push(row);
    previousBalance = row.balance;
  }
});

result.back = $(".hsbcButtonBack:last")[0].href

return result;
