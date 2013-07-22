UserApproval = 
	init: (element) -> 
		@$element = element
		select = element.prev()
		@set_value(select)
		console.log(select.val())

	set_value: ->
		if select.val() == "true"
			select.val("false") 
			this.set_background("Not Approved", "red", "green")
		else
			select.val("true")
			this.set_background("Approved", "green", "red")
		this.submit_form()
			
	submit_form: ->
		@$element.closest("form").unbind('submit').submit()

	set_background: (status, add_color, remove_color) ->
		@$element.html(status).addClass(add_color+"_background").removeClass(remove_color+"_background")

jQuery ->

	# user approval status
	$("body").delegate ".user_ajax_edit .user_approval_status", "click", ->
		UserApproval.init($(this))