var result = {};
var $details = $(".extContentHighlightPib:first");
result.accountName = $.trim($details.find(".hsbcAccountName").text());
result.accountNumber = $.trim($details.find(".hsbcAccountNumber").text());
result.statements = [];

$statementList = $(".extContentHighlightPib:last table")
$statementList.find("td:first-child").each(function() {
  var $row = $(this);
  var $link = $row.find("a")
  var rowDetails = {};
  rowDetails.href = $link[0].href
  rowDetails.title = $link.attr('title')
  result.statements.push(rowDetails);
});

result.nextSet = $(".-arr")[0].href;

return result;
