window.BackToSidebar = 
	init: ->
		$(".middle").remove()
		$("#bid_form").remove()
		$("#view_market_container").remove()
		$("#container_shield").remove()
		$("#dynamic_search").remove()
		$(".side-nav").show()
		$(".side-nav").animate
		  "margin-left": "4px"
		, 300
		$(".left_sub").animate({
			"opacity" : "1"
		}, 200)
		$(".right_sub").animate({
			"opacity" : "0"
		}, 200)
		setTimeout ->
			$(".right_sub").remove()
		, 300
		

window.ShowSidebarTwo =
	init: (action) ->
		$(".side_tab").removeClass("highlight")
		$("#"+action).addClass("highlight")
		$(".side-nav").animate({
			"margin-left" : "-196px"
		},300)
		$(".left_sub").animate({
			"opacity" : "0"
		}, 200)
		$(".right_sub").animate({
			"opacity" : "1"
		}, 200)
		

window.RemoveMktView =
	init: ->
		$("#dynamic_search").remove()
		$("#view_market_container").remove()
		$("#container_shield").remove()
		$(".description").remove()
		$(".middle").remove()
		
window.SetContainerHeight =
	init: ->
		bHeight = $(window).height()
		$("#container").css height: bHeight

jQuery ->
	$("body").delegate ".side_tab.back", "click", ->
		BackToSidebar.init()

	do_nothing = ->
	  false

	# prevent a second click for 10 seconds. :)
	$("body").delegate ".prevent_doubleclick", "click", (e) ->
	  $(e.target).click do_nothing
	  setTimeout (->
	    $(e.target).unbind "click", do_nothing
	  ), 1000

	$(window).resize ->
		browserH = $(window).height()
		browserW = $(window).width()
		$(".side").css "height" : (browserH-57)+"px"
		$("#view_market_container").css "left" : ((browserW-1000)/2)+"px"
		$("#bid_form").css "left" : ((browserW-1000)/2)-25+"px"