class EmailList
	def initialize(time_frame)
		@time_frame = time_frame
	end

	def prayer_list
		prayer_list_array = []
    query.map { |p| prayer_list_array.push(p.id) }
   	prayer_list_array
	end

	def query
		query = {
	    this_week: Prayer.where("prayers.created_at >= ?", Date.today.beginning_of_week),
	    past_week: Prayer.expiring_within_the_week.order("RANDOM() ASC"),
	    past_month: Prayer.expiring_within_the_month.order("RANDOM() ASC")
	  }

	  query[@time_frame]
	end

	def list_for_user(index, user_count)
    user_step_array = ((index)..(prayer_list.count-1)).step(user_count)
    new_prayer_list = []
    user_step_array.each { |c1| new_prayer_list.push(prayer_list[c1]) }
    Prayer.where("id In (?)", new_prayer_list)
	end

end