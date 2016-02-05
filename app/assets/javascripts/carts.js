$(document).ready(function(){
	$(".addedPopup").click(function(){
		// This block of code is literally for finding the values and inserting them into variables
		var itemId, title, price;
		itemId = $(this).parents("div.quantity-box").siblings("div#itemInfo").find("span input#id").val();
		title = $(this).parents("div.quantity-box").siblings("div#itemInfo").children("h4#title").text();
		price = $(this).parents("div.quantity-box").siblings("div#itemInfo").children("div.price").children("span").text();


		var data = {
			item_id: itemId,
			title: title,
			price: price
		};
				message = ""+title+" added to your cart.";
				$(this).parents("div.quantity-box").children("div.addProdModal").find("h4.modal-title").text("Success! Added "+title+" to cart.");
				$(this).parents("div.quantity-box").children("div.addProdModal").find("p#modal-message").text(message);
				$.post('/carts/add/', data);
	});
});
