function helloWorld() {}
function displaySelectedDateTime(dom_id) {
  $(document).ready(function() {
    setInterval(function(){
      $.get('/app/Datetime/selection', {field_key: dom_id}, function(data){
        $('#'+dom_id).val(data);
      });
      return false;
    }, 300);
  });
}

function popupDateTimePicker(flag, title, field_key) {
  $.get('/app/Datetime/popup', { flag: flag, title: title, field_key: field_key });
  return false;
}