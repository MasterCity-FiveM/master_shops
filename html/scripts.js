var zone = null

// Partial Functions
function closeMain() {
	$("body").css("display", "none");
}
function openMain() {
	$("body").css("display", "block");
}
function closeAll() {
	$(".body").css("display", "none");
}
$(".close").click(function(){
    $.post('http://esx_shops/quit', JSON.stringify({}));
});
// Listen for NUI Events
window.addEventListener('message', function (event) {

	var item = event.data;

	// Open & Close main window
	if (item.message == "show") {
		if (item.clear == true){
			$( ".home" ).empty();
			zone = null
		}
		openMain();
	}

	if (item.message == "hide") {
		closeMain();
	}
	
	if (item.message == "add"){
		$( ".home" ).append('<div class="card">' +
					'<div class="image-holder">' +
						'<img src="nui://esx_inventoryhud/html/img/items/' + item.name + '.png" onerror="this.src = \'img/default.png\'" alt="' + item.label + '" style="width:100%">' + 
					'</div>' +
					'<div class="container">' + 
						'<h4><b>' + item.label_fa + '</b></h4> ' +
						'<div class="price" data-price="' + item.price + '" data-maxamount="' + item.maxcount + '">' + item.price + '$' + '</div>' +
						'<div class="quantity">' + 
							'<input name="number" type="range" min="1" max="' + item.maxcount + '" class="amount_buy">' +
						'</div>' +
						'<div class="purchase">' + 
							'<div class="buy" name="' + item.name + '">خرید 1 عدد</div>' + 
						'</div>' +
					'</div>' +
				'</div>');
		
		$('.amount_buy').val('1');
		zone = item.loc;
	}
});

$(".home").on('input', '.amount_buy', function() {
	var AmountRange = $(this);
	var amount = AmountRange.val();
	var paybtn = AmountRange.parent().parent().find(".purchase").find(".buy");
	var price = AmountRange.parent().parent().find(".price").data("price");
	paybtn.html("خرید " + amount + " عدد");
	AmountRange.parent().parent().find(".price").text((price * amount) + "$");
});

$(".home").on("click", ".buy", function() {
	var btnQuan = $(this);
	var itemName = btnQuan.attr('name')
	var ItemCount = parseFloat(btnQuan.parent().parent().find(".amount_buy").val());
	$.post('http://esx_shops/purchase', JSON.stringify({
		item: itemName,
		count: ItemCount,
		loc: zone
	}));
});
