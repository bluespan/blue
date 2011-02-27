$(function() { 
	$(".blue_admin_navigation").lavaLamp({ fx: "easeInQuad", speed: 300, container: 'li', target: "li:not(li li)" });
	$("body:not(.admin) .blue_toolbar").css({opacity:0.25});
	$("body:not(.admin) .blue_toolbar").hoverIntent({
			timeout: 800,
			over: function() {
							$(this).dequeue();
							$(this).animate({top:"0px", opacity:0.9}, {complete: function() { if (this.style.removeAttribute) { this.style.removeAttribute('filter'); } } });
						}, 
			out: function() {
							$(this).dequeue();
							$(this).animate({top:"-45px", opacity:0.25});
						}
	});
	$("body:not(.admin) #blue_toolbar input:checkbox").click(function() {
		$.post("/admin/session/view_live_site", "_method=put&authenticity_token="+form_authenticity_token+"&view_live_site="+(this.checked ? 1 : 0), function(){
			window.location.reload();
		});
	});
	
	// Change Admin Menus
	$("ul.blue_logo").bind("mouseenter", function(){
		
		// Create drop down consisting of all other logos of present toolbars
		var logo_list = $(this).clone().prependTo($(this).parent());
		logo_list.attr("id", logo_list.attr("id") + "_clone")
		logo_list.addClass("blue_choose_logo");
		
		var current_color = $(this).find("li:first").attr("class").split("_");
		current_color = current_color[0];
		
		$(".blue_toolbar:hidden .blue_logo").each(function(){
			$(this).find("li:first").clone().appendTo(logo_list)
		});	
		
		
		logo_list.find("li").click(function(){
			$(".blue_logo").trigger("mouseleave");
			var color = $(this).attr("class").split("_")
			color = color[0];
			
			if (color != current_color) {
				
				$('#'+current_color+'_toolbar').animate({top:"-45px", opacity:0.0}, function() {
					$(this).hide();
					$('#'+color+'_toolbar').css({top:"-45px", opacity:0.0}).show().animate({top:"0px", opacity:0.9}, {complete: function() { if (this.style.removeAttribute) { this.style.removeAttribute('filter'); } } });
				});	
			}
			
		});
				
		logo_list.bind("mouseleave", function(){
			$(this).remove();
		});
	});
	

});