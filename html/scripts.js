var zone = null

var Config = new Object();
Config.closeKeys = [112, 113, 114, 27, 115, 120, 121]; 
$(document).ready(function () {
	$("body").on("keyup", function (key) {
		if (Config.closeKeys.includes(key.which)) {
			$.post("http://master_shops/quit", JSON.stringify({}));
		}
	});
});

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
    $.post('http://master_shops/quit', JSON.stringify({}));
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
		html_out = "";
		$( ".home" ).empty();
		for (const val of item.item) { 
			html_out = html_out + '<div class="card">' +
				'<div class="image-holder">' +
					'<img src="nui://Master_Inventory/html/img/items/' + val.name + '.png" onerror="this.src = \'img/default.png\'" alt="' + val.label + '" style="width:100%">' + 
				'</div><div class="container"><h4><b>' + val.label_fa + '</b></h4> ' +
					'<div class="price" data-price="' + val.price + '" data-maxamount="' + val.maxcount + '">' + val.price + '$' + '</div>' +
					'<div class="quantity">';
					
			if (val.forsell == 1) {
				html_out = html_out + '<input name="number" type="range" min="1" max="' + val.maxcount + '" class="amount_buy">';
			} else {
				html_out = html_out + '<input name="number" type="range" min="1" max="1" class="amount_buy">';
			}
			
			html_out = html_out + '</div><div class="purchase">';
			if (val.forsell == 1) {
				html_out = html_out + '<div class="buy" name="' + val.name + '">خرید 1 عدد</div>';
			} else {
				html_out = html_out + '<div class="buy" name="' + val.name + '">فروش 1 عدد</div>';
			}
			html_out = html_out + '</div></div></div>';
		}
		$( ".home" ).html(html_out);
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
	$.post('http://master_shops/purchase', JSON.stringify({
		item: itemName,
		count: ItemCount,
		loc: zone
	}));
});
