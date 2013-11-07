class DisplayColumns
	def initialize(user, list_type)
		@user = user
		@list_type = list_type
	end

	def product_ids
		@user.product_ids
	end

	def bidding
		Bid.where(user_id:@user.id, product_id:product_ids).where("price > 0").map(&:product_id)
	end

	def watching
		Bid.where(user_id:@user.id, product_id: product_ids).where("price is NULL").map(&:product_id)
	end

	def all
		Product.pluck(:id)
	end

	def every_third_product(col_num, query)
		viewing_col = []
		column = (col_num..(query.count-1)).step(3)
		column.each { |c| viewing_col.push(query[c])}
		viewing_col
	end

	def build_column_for(col_num)
		Product.where("id in (?)", every_third_product(col_num, send(@list_type)))
	end

end
