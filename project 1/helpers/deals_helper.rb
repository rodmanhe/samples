def deal_text(deal, key)
	if deal.new_record?
		text = {
			price: 	"$?",
			button: "Prepare deal price",
			helper: "Click above to set Deal Price",
			submit: "Create Deal"
		}
	else
		text = {
			price: 	"$#{deal.price}",
			button: "Update deal price",
			helper: "Deal is set for:",
			submit: "Update Deal"
		}
	end
	text[key]
end