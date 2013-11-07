class MarketStats
	def initialize(current_user)
		@user = current_user
	end

	def feed 
		%w(new_bids new_watches new_adv_prices new_deals new_products new_members new_retailers)
	end

	def member
		where(user_id: current_user.id)
	end

	def new_bids
		Bid.last_sign_in_at(@user).live_bid
	end

	def new_watches(extra = nil)
		Bid.last_sign_in_at(@user).just_watching
	end

	def new_adv_prices 
		Offer.last_sign_in_at(@user).live_bid
	end

	def new_deals 
		Deal.last_sign_in_at(@user).live_bid
	end

	def new_products 
		Product.last_sign_in_at(@user)
	end

	def new_members 
		User.last_sign_in_at(@user)
	end

	def new_retailers 
		Retailer.last_sign_in_at(@user)
	end

	def run_query

	end

	def query_count(query)
		send(query).count
	end

end

