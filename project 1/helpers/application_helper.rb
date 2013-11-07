## bid prices
	def ranges_up_to(price)
		price = price.to_i
		increment = (price/10).floor
		start, stop = (price-increment), price
		while stop > 0
			start < 0 ? start = 1 : start
			yield start, stop
			start, stop = start-increment, start-1
		end
	end

	## range prices
	def ranges_between(beg_range, end_range)
		range = (end_range.to_i-beg_range.to_i)/8.25.round 
		increment = range > 1 ? range : 1
		beg_range, end_range = beg_range.to_i-increment, end_range.to_i
		start, stop = (end_range), end_range
		while start > beg_range
			yield start, stop
			start, stop = (start-increment), (stop - increment)
		end
	end

	def checkIfShopperHasBids(user)
		bidding_on = three_column_layout_for(user, "bidding")
		bidding_on.blank? ? three_column_layout_for(user, "watching") : bidding_on
	end

	def three_column_layout_for(user, list_type, cat_ids = nil)
    display = DisplayColumns.new(user, list_type)
    (0..2).each do |num| 
      instance_variable_set("@" + "shopper_#{list_type}_col_#{num}", display.build_column_for(num))
    end
  end