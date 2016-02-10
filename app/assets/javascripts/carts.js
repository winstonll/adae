$(document).ready(function(){
	$(".addedPopup").click(function(){
		// This block of code is literally for finding the values and inserting them into variables
		var itemId, title, price;
		itemId = $(this).parents("div.quantity-box").siblings("div#itemInfo").find("span input#id").val();
		title = $(this).parents("div.quantity-box").siblings("div#itemInfo").find("h4#title").text();
		price = $(this).parents("div.quantity-box").siblings("div#itemInfo").find("div.price").children("span").text();
		
		var data = {
			item_id: itemId,
			title: title,
			price: price
		};
				message = "Click Shopping Cart under your account when you're ready for checkout.";
				$(this).parents("div.quantity-box").children("div.addItemModal").find("h4.modal-title").text("Success! Added "+title+" to cart.");
				$(this).parents("div.quantity-box").children("div.addItemModal").find("p#modal-message").text(message);
				$.post('/carts/add/', data);	
	});
});
	

	
	
			 
		
		
