module SharedMethods
  def self.included(base)
    base.class_eval do
    	scope :last_sign_in_at, lambda { |user| where('(created_at > ? or updated_at > ?)', user.last_sign_in_at, user.last_sign_in_at) }
  		scope :live_bid, lambda { where('price IS NOT NULL') }
  		scope :just_watching, lambda { where('price IS NULL') }
  	end
  end
end