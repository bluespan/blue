// Navigations
var mouseOver = []
var mouse = {x:0, y:0};

$(document).ready(function(){
	
	bind_bucket_dialog("#new_bucket_button");
	bind_buckets("#navigations li");

	// Track current mouse position
	
	$(window).mousemove(function(e)
	{
		mouse.x = e.pageX;
		mouse.y = e.pageY;
	});

});

var navigation_dialog = {
	open: function(dialog, link) {
		dialog.overlay.fadeIn('normal')
    dialog.container.slideDown('normal');

		$.ajax({
				url: $(link).attr("href"),
				type: 'get',
				cache: false,
				dataType: 'html',
				success: function (html) {
					dialog.data.html( html ).fadeIn(200);
					dialog.data.find('.close').click(function () { $.modal.close();return false; });
					
					// Add Ajax Submit
					dialog.data.find('form').submit(function(){
						$.post($(this).attr("action") + ".js", $(this).serialize(), null, "script");
						return false;
					});
					
				}
		});
	},
	show: function(dialog) {
	},
	close: function(dialog) {
		dialog.overlay.fadeOut('normal')
		dialog.data.fadeOut('normal'); 
    dialog.container.slideUp('normal', function() {$.modal.close();})
	}
}

function bucket_open(bucket)
{
	var preview = $(bucket).find(".preview");
	var tree = $(bucket).find(".tree");
	preview.css("display", "none");
	tree.css({display:"block", height:"auto"});
}

function bucket_mouseover(e) {

		var preview = $(this).find(".preview");
		var tree = $(this).find(".tree");
		var navigation = $(this);
			
		if (!mouseOver[this.id])
		{
			old_tree_height = tree.css('height');
			tree.css("height", "auto");
			var tree_height = tree.outerHeight();
			
			tree.css("height", old_tree_height);
			
			preview.stop();
			tree.stop();
			preview.css("position", "absolute").animate({opacity:0}, function(){$(this).css("display", "none")})
			tree.animate({opacity:1, height:tree_height+"px"}, function(){$(this).css({height: "auto"})})
			
			mouseOver[this.id] = window.setInterval(function() {
			 if ( navigation.find(".pin").hasClass("pinned") == false &&
						 ((mouse.x < navigation.offset().left || mouse.x > navigation.offset().left + navigation.outerWidth() ) ||
					    (mouse.y < navigation.offset().top  || mouse.y > navigation.offset().top + navigation.outerHeight() )) ) 
				{
					preview.stop();
					tree.stop();
					
					preview.css("display", "block").animate({opacity:1} ,function(){$(this).css("position", "relative")});
					tree.animate({opacity:0, height:"0"}, function(){$(this).css("display", "none")});
					
					clearInterval(mouseOver[navigation.attr('id')]);
					mouseOver[navigation.attr('id')] = null;
				}
			}, 10);
		}
}

function bucket_pin(e) {
	bucket = $(this).parents('.navigation')
	if ($(this).hasClass("pinned")) {
		$.cookie('unpin_bucket_'+bucket.attr('id'), true);
	} else {
		$.cookie('unpin_bucket_'+bucket.attr('id'), null);
	}
	$(this).toggleClass("pinned");
	return false;
}

function bind_bucket_dialog(selector) {
	$(selector).click(function() {
		var link = $(this);
		$("#new_page_dialog").modal({
			onOpen: function(dialog){ page_dialog.open(dialog, link)	},
			onClose: page_dialog.close,		  
			onShow: page_dialog.show,
			containerId: "modalContainerNavigation"
		});
		return false
	});
}

function bind_buckets(selector) {
	// Bind Edit
	bind_bucket_dialog($(selector).find(".edit_navigation"));
	
	if(bind_page_dialog)
	bind_page_dialog($(selector).find(".edit_page"));

	// Bind Delete
	$(selector).find('.delete').click(function() {
		if (confirm("Are you sure you want to DELETE the NAVIGATION: \""+$(this).parent().prev(".title").html()+"?\"")) {
			params = {"_method":"delete", "authenticity_token":form_authenticity_token}
			$.post($(this).attr("href") + ".js", params, null, "script");
		}
		return false
	})
	
	// Bind Mouse Over
	$("#navigations .navigation").bind("mouseover", bucket_mouseover);
	$("#navigations .pin").bind("click", bucket_pin);
	
	// Open state automatically
	$("#navigations .navigation").each(function(){
	  bucket = $(this)
		var pin = bucket.find(".pin");
		if ($.cookie('unpin_bucket_'+this.id) == null && pin.hasClass("pinned") == false) {
			bucket_open(bucket)
			pin.trigger("click")
		}
	})
}

function navigationChange(navigation) {

	// Make navigation change with ajax
	new_location = {}
	if (navigation.next().length > 0)
		new_location = {reference_id:navigation.next().attr('id').replace('navigation_', ''),where:'left'}
	else if (navigation.prev().length > 0)
		new_location = {reference_id:navigation.prev().attr('id').replace('navigation_', ''),where:'right'}
	else if (navigation.parent().parent().attr('id'))
		new_location = {reference_id:navigation.parent().parent().attr('id').replace('navigation_', ''),where:'child'}
	else
		return false;
		
	object = navigation.attr('id').split("_")
	if (object[0] == "page") {
		navigation.addClass("new_page_navigation");
	}
	$.post("/admin/navigations/move.js", $.extend(new_location, {authenticity_token:form_authenticity_token, id: object[1], type:object[0], _method:"put"}), null, "script");	

}

function updateBucketPreviews() {
	// Update Navigation Previews
	$("#navigations .navigation").each(function() {
		var preview = $(this).find(".preview");
		var new_preview_html = "";

		$(this).find(".tree").children("li").each(function(){
			className = $(this).find("div.navigation_page").attr("class")
			className = className.replace("navigation_page ", "").replace("navigation_", "");
			new_preview_html += "<li class='page "+className+"'>"+$(this).find(".title").html()+"</li>"
		});
					
		preview.html(new_preview_html);
	});
}