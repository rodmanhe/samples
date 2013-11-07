class BidSubmission

	attr_accessor :bid 

	def initialize(bid, params = nil)
		@bid = bid
		@params = params
	end

	def create
		if self.bid.save
			self.bid_creation_notifications
		end
	end

	def update
		if self.bid.update_attributes(@params)
			self.bid_update_notifications
		end
	end

	def accept
		self.bid_accept_notification
	end

	def bid_creation_notifications
		# send out mailer to employer for new bid
		# BidMailer.send_message(@bid.task.poster, @bid.bidder).deliver

		# send out notification to employer for new bid
		self.send_alert(:bid_new, @bid, @bid.task.poster)
		
		# send out notifications to employer and bidders if there are 10 bids
		total_bids = @bid.task.bids
		if total_bids.count == 10
	    total_bids.each do |bid|
	      self.send_alert(:bid_pretty_crowded, bid, bid.bidder)
	    end
	    self.send_alert(:many_bids, bid, @bid.task.poster)
		end
	end

	def bid_update_notifications
		UserMailer.send_update_mailer(@bid.task.poster).deliver
		# Resque.enqueue_in(30.seconds, JokketJob::BidUpdateMailer, @bid.task.poster.id)
		self.send_alert(:bid_update, @bid, @bid.task.poster)

	end

	def bid_accept_notification
		self.send_alert(:bid_accepted, @bid, @bid.bidder)
	end

	def send_alert(flag, alertable, receiver)
	  @notification = Notification.find_by_flag(flag)
		alertable.alerts.create!(notification_id: @notification.id, user_id: receiver.id)
	end
end 