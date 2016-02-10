// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready(function(){
	$('.transactions.list_personal_purchases, .transactions.purchase_order').ready(function(){
		$('li.sidebar_personal_purchases').addClass('active');
	});

});