def header_object
	stats = {
		members: @member_sum || User.where(type_of_user:1).count,
		products: @product_sum || Product.all.count,
		watches: @watch_sum || Bid.where('price IS NULL').count,
		bids: @bid_summ || Bid.where('price IS NOT NULL').count
	}
	
end