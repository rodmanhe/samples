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
		Bid.where('created_at > ? AND price IS NOT NULL', @user.last_sign_in_at)
	end

	def new_watches(extra = nil)
		Bid.where('(created_at > ? or updated_at > ?)', @user.last_sign_in_at, @user.last_sign_in_at).where('price IS NULL')
	end

	def new_adv_prices 
		Offer.where('created_at > ?', @user.last_sign_in_at).where('price IS NOT NULL')
	end

	def new_deals 
		Deal.where('created_at > ?', @user.last_sign_in_at).where('price IS NOT NULL')
	end

	def new_products 
		Product.where('created_at > ?', @user.last_sign_in_at)
	end

	def new_members 
		User.where('created_at > ?', @user.last_sign_in_at)
	end

	def new_retailers 
		Retailer.where('created_at > ?', @user.last_sign_in_at)
	end

	def run_query

	end

	def query_count(query)
		send(query).count
	end

end

