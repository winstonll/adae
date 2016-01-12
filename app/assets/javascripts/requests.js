$(document).on('ready page:load', function() {

    // Make sure the add answer button is showing
    $("#add-tag-button").css("display", "inline-block");

    var tagBoxCounter = 4;
    var MAX_BOX_COUNT = 6;

     $("#add-tag-button").click(function() {
       // add another tag text box when clicked under existing text box.
       var newBoxNumber = tagBoxCounter + 1;

       if (newBoxNumber <= MAX_BOX_COUNT) {
         var newHtml = '<input type="text" name="tag_box_' + newBoxNumber +'" id="tag-box-' + newBoxNumber +'" class="tag-box" >';

         $(".tag-input-box").append(newHtml);
         tagBoxCounter++;
       } else {
         $("#add-tag-button").css("display", "none");
       }
     });

	 $('#new_review').on('ajax:beforeSend', function(){
	    $('input[type=submit]').val('Saving....').attr('disabled','disabled');
	  });

	  $('#new_review').on('ajax:complete', function(){
	    $('input[type=submit]').val('Create Review').removeAttr('disabled');
	  });

 });

 