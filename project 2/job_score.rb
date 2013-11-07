class JobScore
	include Math

	def initialize(task, user_type, options = {})
		@task = task
		@user_type = user_type
		@options = options 
	end

	def calculate_score
		# return score unless score.nil? or options[:recompute] == true
  #   return 0 if worker_score_client.nil? or client_score_worker.nil? or winning_bid.nil? or winning_bid.value == 0
    wH = @task.worker.user_honesty
    cH = @task.poster.user_honesty
    
    if @user_type == :employer
    	@part_1 = sgn(cH, wH)
    	@score_add = summed_score("client")
    	@score_diff = diffed_score("client")
    	honest_client_score = weighted_score
      @task.update_attributes(honest_client_score: honest_client_score)
      return honest_client_score
    elsif @user_type == :worker
    	@part_1 = sgn(wH, cH)
      @score_add = summed_score("worker")
      @score_diff = diffed_score("worker")
      honest_worker_score = weighted_score
      @task.update_attributes(honest_worker_score: honest_worker_score)
      return honest_worker_score
    end
	end

	def sgn(main_hon, other_hon)
		hon_mult = main_hon*other_hon
		sin_hon = sin(hon_mult)
		hon_spaceship = main_hon <=> other_hon
		hon_spaceship*(sin_hon/hon_mult)
	end

	def summed_score(anchor)
		contra = anchor == "client" ? "worker" : "client"
		@task.send("#{anchor}_score_#{anchor}") + @task.send("#{contra}_score_#{anchor}")
	end

	def diffed_score(anchor)
		contra = anchor == "client" ? "worker" : "client"
		@task.send("#{anchor}_score_#{anchor}") - @task.send("#{contra}_score_#{anchor}")
	end

	def weighted_score
		(@score_add/2) + (@score_diff/2) * @part_1
	end

end

