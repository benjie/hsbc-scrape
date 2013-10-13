var $els = $('#zczcm .extContentHighlightPib table').find('tr td:first-child .rowEntry');
var accounts = [];
$els.each(function() {
  $el = $(this);
  $a = $el.find('form a');
  $name = $el.find('.rowNo2');
  var account = {name:$.trim($name.text()), details: $.trim($a.attr('title'))};
  accounts.push(account);
});
return accounts;
