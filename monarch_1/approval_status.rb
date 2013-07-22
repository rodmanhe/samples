class ApprovalStatus
	include ApplicationHelper
	def initialize(role, key)
		@role = role
		@key = key
	end

	def find_others(roles)
		o_roles_array = []
		roles.each { |x| o_roles_array.push(x) if yield(x) }
		p o_roles_array
	end

	def other_roles
		roles = %w[admin coordinator intercessor]
		others = find_others(roles) { |x| x != @role.to_s }
		others_array = others.map { |x| Role.find_by_name(x.capitalize).id }
	end

	def query
		User.send(@key).with_role(role_id(@role)).without_role(other_roles)
	end

	def count
		query["#{@role.to_s}_#{@key}"].count
	end
end


# find all admins that are _waiting

# find all coordinators that are waiting, that are not admins or intercessors

# find all ints, that are not admins or coors