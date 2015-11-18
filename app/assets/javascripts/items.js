$(document).on('ready page:load', function() {

 $('#search-form').submit(function(event) {
    event.preventDefault();
    var searchValue = $('#search').val();

      $.getScript('/items?search=' + searchValue);
      
      });

 $('#new_review').on('ajax:beforeSend', function(){
    $('input[type=submit]').val('Saving....').attr('disabled','disabled');
  });

  $('#new_review').on('ajax:complete', function(){
    $('input[type=submit]').val('Create Review').removeAttr('disabled');
  });

 });

 