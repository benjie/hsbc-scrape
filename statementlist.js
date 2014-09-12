var result = {};
var $details = $(".extContentHighlightPib:first");
result.accountName = $.trim($details.find(".hsbcAccountName").text());
result.accountNumber = $.trim($details.find(".hsbcAccountNumber").text());
result.statements = [];

$statementList = $(".extContentHighlightPib:nth(1) table")
$statementList.find("td:first-child").each(function() {
  var $row = $(this);
  var $link = $row.find("a")
  var rowDetails = {};
  rowDetails.href = $link[0].href
  rowDetails.title = $link.attr('title')
  result.statements.push(rowDetails);
});

try {
  // There might not be a next set, this is perfectly valid.
  result.nextSet = $(".-arr")[0].href;
} catch (e) {
  // Meh.
}

return result;
