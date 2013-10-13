var $els = $('#zczcm .extContentHighlightPib table').find('tr td:first-child .rowEntry');
var accounts = [];
$els.each(function() {
  var $el = $(this);
  var $form = $el.find('form');
  var $a = $el.find('form a');
  var $name = $el.find('.rowNo2');
  var account = {
    formId:$form.attr('id'),
    name:$.trim($name.text()),
    details: $.trim($a.attr('title'))
  };
  accounts.push(account);
});
return accounts;
