AdjustColor = 
	init: (e, n, element) -> 
		@$expectedDate = e
		@$newDate = n
		$element = element
		color = @checkValue()
		$element.parent()
							.next().css("background", color)
						.end()
							.find(".helper_text").remove()
						.end()
							.closest(".milestone-container")
								.append("<div class='helper_text'>"+@matchText(color)+"</div>")

	checkValue: ->
		color = switch
			when @$expectedDate < @$newDate then "red"
			when @$expectedDate == @$newDate then "yellow"
			else	"green"
			
	matchText: (key)->
		match_hash =
		  red: "after Date: Bad"
		  yellow: "on Date: OK"
		  green: "before Date: Great"
		match_hash[key]

jQuery ->
	$("body").delegate ".milestone-container .milestone_date input", "click", ->
		$(this).datepicker(dateFormat: "dd-mm-yy")

	$("body").delegate ".milestone-container .milestone_date input", "change", ->
		expectedDate = $(this).data("expected-date")
		newDateValue = $(this).val()
		newDate = newDateValue.split("-").reverse().join("-")
		$ele = $(this)
		AdjustColor.init(expectedDate, newDate, $ele)