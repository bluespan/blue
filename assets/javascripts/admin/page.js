$(document).ready(function(){
	bind_page_dialog("#new_page_button");
	bind_pages("#pages .list li");

	$('#navigations .navigation .tree, #pages .list').jTree({onChangeCallback:navigationChange});
	
	// Page List
	$("#search input").keyup(function() {
		var search = $(this);

		$("#pages .list li").each(function(){
			var page = $(this);
			var hit = 0;
			$(page.find(".title").html().split(" ")).each(function(){
				if (this.toLowerCase().indexOf(search.val().toLowerCase()) == 0)
					hit++;
			});
			
			if (hit)
				$(this).css({"display":"block"});
			else
				$(this).css({"display":"none"});

		});
	});
	
});


// Page Dialogs
var page_dialog = {
	display: function(dialog, link, html) {

		dialog.data.find('.loading').fadeOut(150, function() {

			dialog.data.html('<div class="content" style="display:none;">' + html + '</div>');
		
			dialog.data.find('.close').click(function () { $.modal.close();return false; });
			dialog.data.find('ul.tags li').click(function() {$(this).toggleClass("use")});
		
			// Bind Video Tray
			var video_select_dialog = blue_video_select_dialog({current_dialog: current_dialog});
	  	video_select_dialog.init();
			
			// Add Ajax Submit
			dialog.data.find('form').submit(function(){
				$.post($(this).attr("action") + ".js", $(this).serialize(), null, "script");
				return false;
			});
			
			// Add typecast
			$("#page_type").bind("change", function(){
				form = dialog.data.find('form');
				
				dialog.data.html('<div class="loading"></div>').fadeIn(100, function(){
					$.ajax({
									url: link.attr("href"),
									type: 'get',
									data: form.serialize(),
									cache: false,
									dataType: 'html',
									success: function (html) {
										page_dialog.display(dialog, link, html);
									
									}
							});
					});
				});
				
				
			dialog.data.find('.content').fadeIn(500);
		});
	},
	open: function(dialog, link) {
		dialog.overlay.fadeIn('normal')
    dialog.container.slideDown('normal');
		dialog.data.html('<div class="loading"></div>').show();
		page_dialog = this
		$.ajax({
				url: $(link).attr("href"),
				type: 'get',
				cache: false,
				dataType: 'html',
				success: function (html) {
					page_dialog.display(dialog, link, html);
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

var current_dialog;
function bind_page_dialog(selector) {
	$(selector).click(function() {
		var link = $(this);
		current_dialog = $("#new_page_dialog").modal({
			onOpen: function(dialog){ page_dialog.open(dialog, link)	},
			onClose: page_dialog.close,		  
			onShow: page_dialog.show
		});
		return false
	});
}

function bind_pages(page) {
	// Bind Edit
	bind_page_dialog($(page).find(".edit_attributes"));
	
	// Bind Delete
	$(page).find('.delete').click(function() {
		if (confirm("Are you sure you want to DELETE the PAGE: \""+$(this).parents(".page").find(".title").html()+"?\"")) {
			params = {"_method":"delete", "authenticity_token":form_authenticity_token} 
			$.post($(this).attr("href") + ".js", params, null, "script");
		}
		return false
	})
}


blue_video_select_dialog = function(options) {
  var blue_video_select_dialog = new BlueVideoSelectDialog(options);
  return(blue_video_select_dialog);
};

function BlueVideoSelectDialog(options) {
	this._options = options;
};

BlueVideoSelectDialog.prototype.init = function() {

  var blue_video_select_dialog = this;
  
  //handle click event

		jQuery("#video_settings #browse_video").click(function(){
	    blue_video_select_dialog.open("/admin/videos");
			return false;
		});

};

BlueVideoSelectDialog.prototype.open = function(path) {

	var current_dialog = this._options.current_dialog;

	current_dialog.toggleRightTray({width:400, 
		onopen:function() {
			var tray_dialog = current_dialog.dialog.rightTray.find(".trayDialog .content");
			var tray_loading = current_dialog.dialog.rightTray.find(".trayDialog .loading");

			tray_dialog.hide();
			tray_loading.show();	

			$.get(path, {}, function(data) {

				tray_dialog.html(data);
				
				tray_dialog.find("li").click(function() {
					jQuery("#selected_video img").attr("src", $(this).find("img").attr("src"));
					jQuery("#selected_video label").html($(this).find(".title").html());
					jQuery("#selected_video input").val($(this).attr("id"));
					return false
				});
				
				tray_dialog.find("#options .cancel").click(function() {
					current_dialog.closeRightTray();
				});

				tray_loading.fadeOut(150, function() {
					tray_dialog.fadeIn(150);
				});
			});
		}
	});
};


