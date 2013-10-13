var result = {};
var $details = $(".extContentHighlightPib:first");
result.accountName = $.trim($details.find(".hsbcAccountName").text());
result.accountNumber = $.trim($details.find(".hsbcAccountNumber").text());

var $statement = $(".extContentHighlightPib:last");
result.date = $.trim($statement.find(".extPibRow:nth-of-type(1) .hsbcTextRight").text());
result.rows = [];

var $rows = $statement.find("table tbody tr");
$rows.each(function(){
  var $row = $(this);
  var row = {}
  var fields = ['date', 'type', 'description', 'out', 'in', 'balance'];
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
  result.rows.push(row);
});

result.back = $(".hsbcButtonBack")[0].href

return result;
